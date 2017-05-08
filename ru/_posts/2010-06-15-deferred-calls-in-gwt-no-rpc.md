---
layout: post.html
title: Deferred-вызовы серверного API в GWT (без RPC)
datetime: 15 Jun 2010 09:32
tags: [ gwt, java, json ]
---

**Deferred** - _зд._ термин, который применяется для описания **вложенных асинхронных вызовов**, см. например [Deferred в Javascript](http://javascript.ru/unsorted/async/deferred-deep) и конкретно [Deferred в Dojo framework](http://api.dojotoolkit.org/jsdoc/1.3/dojo.Deferred). _Не путать с Deferred Binding_.

------

> Заранее отмечу, что статья никак не связана с GWT-RPC и описывает только _"нативные"_ вызовы серверного API. GWT-RPC ограничивает возможности крупных проектов тем, что на серверной строне может использоваться только Java, в нашем случае я хочу избавить разработчика клиентской стороны от таких ограничений, поэтому использую `RequestBuilder` напрямую.

Как известно, в GWT рекомендуется придерживаться _асинхронных_ вызовов и полагаться только на них.

Представим, что есть некое API, располагающееся на том же сервере, что и GWT-приложение. API предоставляет набор функций, которые можно вызывать по адресу вроде `http://127.0.0.1/api/do.something?param1=foo&param2=bar` (или POST-запросом, неважно). Допустим, это API возвращает JSON-объекты в виде ответа. Если делать все функции в таком API атомарными, то рано или поздно придётся последовательно делать цепочки асинхронных запросов вроде `user.new` (передаётся юзернейм и возвращется id пользователя), затем `session.new` (только если `user.new` исполнился корректно, передаём полученный id пользователя, получаем id сессии), затем `group.enter` (только если `session.new` исполнился корректно, передаём id юзера и id сессии), ну и так далее. Если какой-то запрос в цепочке свалился, то считается, что вся цепочка не сработала (а обычно требуется именно чтобы такая цепочка сработала вся до конца). Такие цепочки вызовов называются _вложенными_ и к ним принято применять термин _Deferred_.

Итак, чтобы общаться с описанным API, нужно написать некий, простой в использовании, Java-GWT код, который будет позволять вызывать такие цепочки. О таком коде я последовательно и расскажу.

------

Ниже 'хэшами' я называю `HashMap`'ы, если не указано иного - просто для краткости, с `HashSet`'ами и md5/sha-хэшами они не имеют ничего общего. В JavaScript это объекты, в PHP/Perl - хэш-массивы, в Python - словари. Не в том смысле, что это идентичные вещи, а в том, что это сходные концепции.

Условимся, что API возвращает JSON-объекты, поля у которых варьируются, но всегда присутствует поле `"status"`, равное `"error"` (тогда присутствет также поле `"description"`) или `"ok"`.

Для примера возьмём цепочку (названия функций говорят сами за себя, поэтому их назначения пояснять не буду):

* `user.enter` - принимает `username=foo` и возвращает `{ 'status': 'ok', 'uid': 50 }`
* `session.new` - не принимает ничего и возвращает `{ 'status': 'ok', 'sid': '0e05bf5e-b521-46bf-8bf4-b017c7efd3d2' }`, если пользователь вошёл
* `group.enter` - принимает `sid=0e05bf5e-b521-46bf-8bf4-b017c7efd3d2` и `gid=somegroup` и возвращает `{ 'status': 'ok', 'master': 'true' }`. Если группа не существует, она автоматически создаётся.
* `group.users` - принимает `gid=somegroup` и возвращает `{ 'status': 'ok', 'users': ['bill', 'steve', 'sergey', 'linus'] }`
* `group.getmessages` - принимает `gid=somegroup`, `start_from=20` и возвращает  `{ 'status': 'ok', 'count': 3, 'messages': ['helloall', 'hows iPad?', 'seems it sucks', 'forget about it'] }`
* если произошла ошибка, она возвращается в виде `{ 'status': 'error', 'code': 200, 'description': 'Wow!'}`

Общая идея такова: Поскольку между вызовами возвращаемые и передаваемые параметры обычно имеют одинаковые имена (или, лучше сказать, _обязаны_ иметь), то вполне достаточно иметь между этими вызовами некий общий контекст, в который будут складываться возвращённые параметры и из которого будут вытаскиваться те параметры, которые нужно передать. Такой контект можно предварительно подготовить, заранее установив в него уже известные переменные и передавать его, обновляя, сквозь все функции.

Дополнительное преимущество такого подхода состоит в том, что _вообще все_ цепочки могут иметь _один общий_ контекст, в котором всегда будет доступен, например, последний ID сессии (будет замещён по ключу в хэше после каждого вызова `session.new`) или хранить GUID последнего запроса, если условиться возвращать его в каждой функции, или верифицировать любой процесс приёма-отдачи засчёт установки некой переменной в контексте в ожидаемое значение и проверять его после выполнения запроса и т.п.

Поэтому такой контекст может быть обычным `HashMap<String, Object>`:

``` java

public class APICallContext extends HashMap<String, Object> { }

```

Кода относительно много, поэтому начнём с конца и подготовим всё небходимое для вызова цепочки. Все без исключения внешние импорты берутся из пакетов  `com.google.gwt....` и `java.util`, поэтому я их не буду указывать.

Опишем интерфейс хэндлера, который будет срабатывать после успешного вызова _каждой_ функции в цепочке (`statusCode == 200`, `'status': 'ok'`):

``` java

public interface APIResponseHandler {
    public void handleResponse(JSONObject answer);
}

```

Опишем интерфейс хэндлера, который будет срабатывать после того, как выполнение _всей_ цепочки закончилось успешно и получать изменённый, в соответствии с ответами на запросы, контекст:

``` java

public interface APIChainResponseHandler {
    public void handleSuccess(EurekaAPICallContext context);
}

```

Опишем интерфейс хэндлера, который будет срабатывать после _первого_ неудачного вызова функции из цепочки:

``` java

public interface APIErrorHandler {
    public void handleError(String errorText);
}

```

В результате, вызов цепочки будет совершаться через передачу следующих параметров

* Списка из названий (алиасов) функций, которые требуется выполнить. Напр., `["user.new", "session.new", "page.enter"]`.
* Подготовленного контекста, или `null`, тогда перед выполнением цепочки будет создан пустой контекст
* Хэндлера, который сработает после успешного выполнения всей цепочки (все функции вернули `'status': 'ok'`)
* Хэндлера, который сработает после первого неудачного вызова одной из функций в цепочке (как минимум одна функция вернула `'status': 'error'`)

Так будет выглядеть описание функции, вызывающей такую цепочку:

``` java

public void callServerFuncsChain(List<String> funcsCodes, APICallContext context,
                                 APIChainResponseHandler finalSuccessHandler, APIErrorHandler errorHandler);

```

Любой из хэндлеров можно передать как `null`, тогда в соответствующем случае просто ничего не будет вызвано.

Создадим оборачивающий класс, который будет управлять связью с API и вставим в него все приведённые выше интерфейсы:

``` java

public class APIConnector {

    @SuppressWarnings("serial")
    public class APICallContext extends HashMap<String, Object> { }

    public interface APIResponseHandler {
        public void handleResponse(JSONObject answer);
    }

    public interface APIErrorHandler {
        public void handleError(String errorText);
    }

    public interface APIChainResponseHandler {
        public void handleSuccess(EurekaAPICallContext context);
    }
}

```

Укажем в этом классе общий URL API, к которому он будет подключаться:

``` java

public static final String SERVER_URL = "http://127.0.0.1/api";

```

Опишем в нём хэш, который будет содержать данные о том, какие параметры необходимо передавать в каждую из функций API. Если функция не принимает параметров - её можно не указывать.

``` java

public class APIConnector {

    public static final String SERVER_URL = "http://127.0.0.1/api";

    private static final Map<String, List<String>> apiFuncsMap = new HashMap<String, List<String>>();

    static {
        apiFuncsMap.put("user.enter", "username");
        // apiFuncsMap.put("session.new", null);
        apiFuncsMap.put("group.enter", Arrays.asList("sid", "gid"));
        apiFuncsMap.put("group.users", Arrays.asList("gid"));
        apiFuncsMap.put("room.getmessages", Arrays.asList("gid", "start_from"));
        apiFuncsMap.put("group.say", Arrays.asList("gid", "gid", "message"));
    };

```

Опишем те параметры, которые можно не сохранять в контексте, дабы его не засорять:

``` java

    private final Set<String> filterFields = new HashSet<String>(Arrays.asList("status", "description"));

```

Пусть класс будет иметь возможность работать в одном из режимов: `GET` или `POST` и принимать для этого в конструктор boolean-параметр `getMode`, при значении `true` будет включаться режим `GET`, при значении `false` - `POST`

``` java

    private final boolean getMode;

    public APIConnector(boolean getMode) {
        this.getMode = getMode;
    }

```

Теперь напишем собственно метод, который будет делать единственный вызов единственной функции API и после удачного вызова вызывать хэндлер `successHandler`, а после неудачного - `errorHandler`. Для этого используется GWT-класс `RequestBuilder`, который в скомпилированной версии генерирует известный нам AJAX-вызов через `XMLHttpRequest` (согласно браузеру). Методу также передаётся список параметров функции/запроса в виде `Map<String, String>`.

Кроме этого требуется указать коллбэк, который будет вызван из GWT после асинхронного вызова, для этого дополнительно опишем внутренний класс. И, будем запоминать последнюю ошибку на всякий случай (обратите внимание, как обрабатывается ошибка в коллбэке):

``` java

private boolean wasError = false;
private String lastErrorText = null;

protected void callServerFunc(String funcCode, Map<String, String> params,
                              APIResponseHandler successHandler,
                              APIErrorHandler errorHandler) {
    StringBuffer url = new StringBuffer();
    url.append(SERVER_URL + "/");
    url.append(funcCode);
    if (getMode && (params != null)) url.append("?" + prepareParams(params));

    forgetErrors();

    RequestBuilder builder = new RequestBuilder(
                        getMode ? RequestBuilder.GET : RequestBuilder.POST,
                        url.toString());

    if (!getMode) {
        builder.setHeader("Content-Type", "application/x-www-form-urlencoded");
        builder.setRequestData(prepareParams(params));
    }
    builder.setCallback(new APIRequestCallback(successHandler, errorHandler));

    try {
        builder.send();
    } catch (RequestException e) {
        storeError("Couldn't retrieve data because of request exception. " + e.toString());
    } catch (Exception e) {
        storeError("Unknown Exception: " + e.toString());
    }
}

protected static String prepareParams(Map<String, String> params) {
    if (params != null) {
        StringBuffer result = new StringBuffer();
        for (Iterator<Map.Entry<String, String>> iter = params.entrySet().iterator(); iter.hasNext(); ) {
            Map.Entry<String, String> param = iter.next();
            result.append(URL.encode(param.getKey()) + "=" + URL.encode(param.getValue()));
            if (iter.hasNext()) result.append("&");
        }
        return result.toString();
    } else return "";
}

private void forgetErrors() {
    wasError = false;
    lastErrorText = null;
}

private void storeError(String errorText) {
    wasError = true;
    lastErrorText = errorText;
}

public final class APIRequestCallback implements RequestCallback {

    private final APIResponseHandler successHandler;
    private final APIErrorHandler errorHandler;

    public APIRequestCallback(APIResponseHandler successHandler,
                              APIErrorHandler errorHandler) {
        this.successHandler = successHandler;
        this.errorHandler = errorHandler;
    }

    public APIRequestCallback(APIResponseHandler successHandler) {
        this(successHandler, null);
    }

    private void handleError(String error) {
        if (errorHandler != null) errorHandler.handleError(error);
        storeError(error);
    }

    public void onError(Request request, Throwable exception) {
        handleError("Can't get JSON data: "  + exception.getMessage());
    }

    public void onResponseReceived(Request request, Response response) {
        if (200 == response.getStatusCode()) {
            // FIXME: check if response is trusted
            JSONValue value = JSONParser.parse(response.getText());
            if (value != null) {
                JSONObject answer = value.isObject();
                if (answer != null) {
                    if (successHandler != null) successHandler.handleResponse(answer);
                } else {
                    handleError("Returned JSON can not be parsed as object");
                }
            } else {
                handleError("Returned response can not be parsed as JSON");
            }
        } else {
            handleError("Can't get JSON data (" + response.getStatusText() + ")");
        }
    }

}

```

Также этот метод использует встроенный в GWT JSON-парсер. Кроме всего прочего, он убежден, что из запроса ему приходит правильный JSON-объект поэтому от всех функций API требуется, соответственно и разумеется, чтобы они возвращали JSON-объект. Если какой-то из хэндлеров успеха/ошибки не объявлен - в соответствующих случаях ничего не будет вызвано.

Настало время написать приватный метод, который будет вызывать одну функцию из цепочки зная о том, что при удаче ему нужно вызвать следующую, при ошибке - `errorHandler`, а при заключительном успехе - `finalSuccessHandler` (обратите внимание, что это другой интерфейс -  этот хэндлер вызывается не для каждой функции, а только при условии успеха выполнения всей цепочки).  Для этого кроме имени текущей выполняемой функции API ему будет передаваться итератор по именам из цепочки функций, и собственно оба хэндлера. Если следующей функции нет - цепочка окончена - будет вызваться хэндлер успеха,  если она есть - рекурсивно будет вызван тот же самой метод, уже для следующей функции, со сделавшим шаг итератором.

``` java

private void callChainFunc(String function, final Iterator<String> funcsIter,
                           final APICallContext context,
                           final APIChainResponseHandler finalSuccessHandler,
                           final APIErrorHandler errorHandler) {
    List<String> requiredParams = apiFuncsMap.get(function);
    Map<String, String> params = null;
    if (requiredParams != null) {
        params = new HashMap<String, String>();
        for (String paramName: requiredParams) {
            if (context.get(paramName) == null) {
                throw new IllegalArgumentException("Required parameter value '"
                            + paramName + "' for function '" + function + "' was not found in API context");
            }
            params.put(paramName, context.get(paramName).toString());
        }
    }
    callServerFunc(function, params, new APIResponseHandler() {

        @Override
        public void handleResponse(JSONObject answer) {
            boolean wasError = "error".equalsIgnoreCase(answer.get("status").toString().replace("\"", ""));
            if (wasError) {
                errorHandler.handleError("received error status " + answer.get("description").toString());
                return;
            }
            Set<String> keys = answer.keySet();
            for (String key: keys) {
                if (!filterFields.contains(key)) {
                    context.put(key, answer.get(key));
                }
            }
            if (funcsIter.hasNext()) {
                callChainFunc(funcsIter.next(), funcsIter, context, finalSuccessHandler, errorHandler);
            } else {
                if (finalSuccessHandler != null) finalSuccessHandler.handleSuccess(context);
            }
        }

    }, errorHandler);
}

```

Метод, как видно, передаёт каждой функции в вызов только необходимые параметры, описанные в хэше c функциями, приведённом выше, берёт их значения из контекста и, после выполнения запроса, устанавливает в контекст по полям все значения из ответа, исключая поля указанные в фильтре, также приведённом выше. Поскольку данные в контекст могут быть установлены и из Java-кода заранее - значения в контексте это нативные объекты, а не строки или объекты JSON.

И, наконец, внешний (публичный) метод, который позволит запустить весь процесс и который мы декларировали в самом начале. Он берёт итератор по списку функций, передаёт первую функцию из списка и сам этот итератор в тот самый приватный метод, который мы только что написали. Хэндлеры уходят туда же.

``` java

public void callServerFuncsChain(List<String> funcsCodes, final APICallContext context,
                                 final APIChainResponseHandler finalSuccessHandler,
                                 final APIErrorHandler errorHandler) {
    if (!funcsCodes.isEmpty()) {
        final Iterator<String> funcsIter = funcsCodes.iterator();
        callChainFunc(funcsIter.next(), funcsIter, context, finalSuccessHandler, errorHandler);
    }
}

```

Можно насоздавать алиасов для этого метода, требующих меньшего количества параметров - в качестве любого из хэндлеров позвояляется передавать `null`, а контекст при его отсутствии можно создавать на месте через `new APICallContext()`.

Кстати, метод, который помогает внешнему пользователю создать контекст (это не статический метод, поскольку для внутреннего класса необходимо присутствие инстанса):

``` java

    public APICallContext newCallsContext() {
        return new APICallContext();
    }

```

Теперь, пример использования. Общий контекст для всех цепочек можно хранить в приватном поле и передавать при соответствующей необходимости:

``` java

public abstract class UsersGroup {
    private final APIConnector apiConnector = APIConnector.getInstance(); // удобнее сделать APIConnector синглтоном
    private final APICallContext apiContext = apiConnector.newCallsContext();

    private final String username = "shamansir";
    private final String groupname = "testgroup";

    public void enterGroup() {
        apiContext.put("rid", roomname);
        apiContext.put("start_from", 0);
        apiContext.put("username", username);
        apiConnector.callServerFuncsChain(Arrays.asList("user.get",
                                                        "session.new",
                                                        "group.enter",
                                                        "group.users",
                                                        "group.getmessages"),
                        apiContext, new APIChainResponseHandler() {

                            @Override
                            public void handleSuccess(APICallContext context) {
                                username = context.get("username").toString();
                                onMessagesReceived(
                                    Integer.parseInt(context.get("count").toString()),
                                    (JSONArray)context.get("messageslist"));
                                onParticipantsReceived(
                                    (JSONArray)context.get("users"));
                                onAfterEnter();
                            }

                        }, new APIErrorHandler() {

                            @Override
                            public void handleError(String errorText) {
                                Window.alert("Error: " + errorText);
                            }

                        });

    }

    abstract void onParticipantsReceived(JSONArray participants);
    abstract void onMessagesReceived(int count, JSONArray messages);

}

```

Можно, конечно, использовать, отдельный контекст для цепочки, который заранее подготавливается. А можно, опять же, передавать `null` :).

Если вы предпочитаете не пользоваться вызовами `Arrays.asList` используйте инстансы `LinkedList` - помните, что важен порядок.

Если необходимо известить о принятых объектах несколько целей, можно использовать механизм событий `GwtEvent<H>` из самого GWT или паттерн шины событий.

Что ж, на этом всё, спасибо за внимание. Прошу указывать на ошибки и возмущаться. если есть повод.
