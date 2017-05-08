---
layout: post.html
title: Java + JSON
datetime: 25 May 2008
tags: [ java, json, javascript ]
---

### Введение

Спешу поделиться результатами небольшого исследования, оказавшегося необходимым для текущего проекта. Рассматривается возможность связки Java и JSON, её преимущества и недостатки. Я расскажу о практической части, о теории больше поведают нижеприведённые ссылки (_англ._).

* [Mastering JSON](http://www.hunlock.com/blogs/Mastering_JSON_\(_JavaScript_Object_Notation_\)) -- самая приятная статья по JSON, описывающая все основные принципы и дополнительные возможности
* [Использование JSON для передачи данных посредством AJAX](http://www.ibm.com/developerworks/xml/library/wa-ajaxintro10/) в статье от IBM
* [Описание](http://www.json.org/js.html) связи JSON и JavaScript на официальном сайте
* [Краткое описание](http://json.org/java/simple.txt) скрещивания JSON и Java на официальном сайте
* [Java-классы](http://json.org/java/) на официальном сайте
* [Способы сериализации](http://www.ibm.com/developerworks/library/j-ajax2/) Java-объектов в статье от IBM
* [И ещё](http://twit88.com/blog/2007/11/20/serialize-java-object-to-json-string/) о сериализации JSON-объектов в строку
* [JSONTools](http://jsontools.berlios.de/) для Java

Если кратко -- JSON (JavaScript Object Notation) не является ничем более сложным, чем описано в его названии. Если вы можете описать сложно-структурированный объект на JavaScript -- то о клиентской стороне JSON вы знаете практически всё. Серверная часть JSON занимается тем, что принимает каким-либо способом объект, записанный в нотации JavaScript и разворачивает данные таким образом (наверное можно сказать, десериализует), чтобы они стали доступны (или хотя бы понятны :) ) остальной части кода.

Не скажу корректно о других языках, но для Java код приёма объекта вам придётся написать самим (если только я не пропустил что-то очевидное) -- ну и это не так сложно, поскольку всё необходимое [для разворачивания объекта](http://json.org/java/) доступно на [сайте JSON](http://json.org/). Ммм, я сказал только "разворачивания"? Простите, и сворачивания тоже. Засчёт приведённого кода вы можете, например, создать Java-проекцию объекта в JavaScript-нотации (далее — JSON-объект) из `JavaBean`‘а (с некоторыми оговорками, о которых ниже), из `java.util.Map`, или, собственно, из строки в этой нотации.

Я не буду приводить примеров объектов на JSON, их доступно изрядно по ссылкам выше, да и зная JavaScript, как я уже говорил -- вы знаете JSON. Обращу ваше внимание на то, что с передачей JSON-объектов следует быть осторожными и всё время помнить, что недоброжелатель, знающий серверные технологии и JavaScript, если захочет -- эту лазейку, наверное, найдёт в первую очередь. Вспоминайте ваши любимые методы JavaScript и Java-секьюрности -- это несколько сторонняя тема, об этом я здесь рассказывать не буду. И, кстати, передача JSON-объектов — это ещё и [протокол](http://json-rpc.org/wd/JSON-RPC-1-1-WD-20060807.html).

### Описание

Итак, практика. Я выбрал путь общего Java-сервлета для принятия (или раздачи) всех JSON-объектов в приложении и менеджера, ему их подготавливающего (или от него их принимающего). Для того, чтобы было легче создавать JSON-объекты на основе Java-объектов я выбрал путь JavaBean‘ов, JSON для Java умеет на их основе (засчет геттеров) создавать JSON-объект, а нам достаточно написать код для обратного действия. Для объектов со сложной структурой наверняка понадобится эти методы переопределять, поэтому я выделил их в отдельный абстрактный класс, который должен стать отцом для всех объектов, которые будут передаваться между сервером и клиентом. В качестве бонуса, в конце статьи представлены несколько кривенькие, но читабельные, диаграмма классов и диаграмма последовательностей этой небольшой конструкции.

### Процесс

В первую очередь соберём `jar`-библиотеку JSON, поскольку для Java этот пакет поставляется [в исходниках](http://www.json.org/java/json.zip) (описание сборки позаимствовано [отсюда](http://processing.org/discourse/yabb_beta/YaBB.cgi?board=Integrate;action=display;num=1163101573) и вы можете спокойно пропустить эту часть, если свободно собираете `jar`‘ы из исходников или вам это не требуется):

1. Сохраните [пакет](http://www.json.org/java/json.zip) в какой-либо каталог, который будет далее называться `%DOWNLOAD_HOME%`
1. Распакуйте его и убедитесь, что структура каталогов (`/org/json/`) не изменилась.
1. Перейдите в каталог `%DOWNLOAD_HOME%/org/json/`
1. Скомпилируйте классы командой `javac *.java`
1. Вернитесь в каталог `%DOWNLOAD_HOME%`
1. Командой `jar -cvf json.jar org\json\*.class` создайте `jar`-архив.
1. Добавьте библиотеку в ваш проект

Теперь приведу код интерфейса `IJSONSerializable` (объекта, который может быть свёрнут в `JSON` и развернут обратно -- думаю, это довольно корректно) и абстрактного класса `JSONBean`, который его имплементирует.

``` java

package com.acme.json;

import org.json.JSONObject;

public interface IJSONSerializable {

    public boolean fromJSONObj(JSONObject object);

    public JSONObject toJSONObject();

}

```

Обратите внимание, что в стандартной версии JSON по геттерам считает за пары ключ-свойство значения некоторых недозволенных методов, например, `getClass` и `getInstance` — нижеприведённый класс этот недостаток (в случае указанных методов) обходит и, собственно, добавляет функциональность конструирования (а в данном случае правильнее -- инициализации) `Bean`‘а из JSON-объекта. Да, здесь, иcпользуется `reflection`, и если вас не устраивает этот факт -- вы вольны поменять концепцию :) -- JSON выстраивает свой объект из `Bean`‘а точно таким же способом.

``` java

package com.acme.json;

import java.lang.reflect.Method;

import org.json.JSONException;
import org.json.JSONObject;

public abstract class JSONBean implements IJSONSerializable {

    public boolean fromJSONObj(JSONObject jsonObj) {
        Class beanClass = this.getClass();
        Method[] methods = beanClass.getMethods();
        for (int i = 0;  i < methods.length; i += 1) {
            try {
                Method method = methods[i];
                String name = method.getName();
                String key = "";
                if (name.startsWith("set")) {
                    key = name.substring(3);
                }
                if (key.length() > 0 &&
                        Character.isUpperCase(key.charAt(0)) &&
                        method.getParameterTypes().length == 1) {
                    if (key.length() == 1) {
                        key = key.toLowerCase();
                    } else if (!Character.isUpperCase(key.charAt(1))) {
                        key = key.substring(0, 1).toLowerCase() +
                            key.substring(1);
                    }
                    if (isAllowedKey(key))
                        method.invoke(this, jsonObj.get(key));
                }
            } catch (Exception e) {
                return false;
            }
        }
        return true;
    }

    public JSONObject toJSONObject() {
        return new JSONObject(this) {
            @Override
            public Object get(String key) throws JSONException {
                return isAllowedKey(key) ? super.get(key) : null;
            }
        };
    }

    protected static boolean isAllowedKey(String key) {
        return ((key != "class") && (key != "instance"));
    }

}

```

Ну, и простенький пример `Bean`‘а, с которым мы будем работать.

``` java

package com.acme.json.beans;

import com.acme.json.JSONBean;

public class PersonBean extends JSONBean {

    private String personFirstName = "Homer";
    private String personLastName = "Simpson";
    private int personAge = 46;

    public String getPersonFirstName() {
        return personFirstName;
    }

    public void setPersonFirstName(String personFirstName) {
        this.personFirstName = personFirstName;
    }

    public String getPersonLastName() {
        return personLastName;
    }

    public void setPersonLastName(String personLastName) {
        this.personLastName = personLastName;
    }

    public int getPersonAge() {
        return personAge;
    }

    public void setPersonAge(int personAge) {
        this.personAge = personAge;
    }

}

```

`JSONBeanManager` управляет подготовкой `Bean`‘ов для отправки и принятия их на основе параметров запроса. Думаю, концентрация этого кода в одном месте оправдана, поскольку вы вряд ли захотите, чтобы отвечающий за пересылку `Bean`‘ов код был разбросан по проекту. В худших случаях паттерны проектирования придут вам на помощь. Кстати, возможно вы захотите сделать некоторые ваши `Bean`‘ы `Singleton`‘ами, тогда здесь вы можете возвращать их единственные инстансы (не забудьте только, что в связи с этим их нужно аккуратнее готовить :) ).

``` java

package com.acme.json;

import java.util.Map;

import com.acme.json.beans.PersonBean;

public class JSONBeanManager {

    protected JSONBean prepareBeanForReceiving(Map parametersMap) {
        if (parametersMap.containsKey("source") &&
           (parametersMap.get("source") == "sampleBean")) {
            return new PersonBean();
        }
        return null;
    }

    protected JSONBean prepareBeanForSending(Map parametersMap) {
        if (parametersMap.containsKey("source") &&
           (parametersMap.get("source") == "sampleBean")) {
            return new PersonBean();
        }
        return null;
    }

    protected void onBeanReceived(JSONBean bean) { }

    protected void onBeanSent(JSONBean bean) { }

    protected void onBeanTransferError() { }

}

```

Ну и наконец -- сервлет. Ядро пересылки. Запрос `GET` на сервер отправляет клиенту `Bean`, отданный менеджером на основе анализа параметров запроса, а затем сконвертированный в JSON-объект, а `POST` -- принимает и заполняет предоставленный тем же менеджером `Bean` полученными из JSON-объекта данными.

``` java

package com.acme.json;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONException;
import org.json.JSONObject;

public class JSONBeanServlet extends HttpServlet {

    protected static final String JSON_OBJ_PARAM = "jsonBean";

    private JSONBeanManager beanManager = null;

    public JSONBeanServlet(/*Class beanManagerClass*/) {
        super();
        this.beanManager = new JSONBeanManager();
    }

    @Override
    public void doGet(HttpServletRequest req,
            HttpServletResponse resp)
            throws java.io.IOException, ServletException {
        JSONBean activeBean =
            beanManager.prepareBeanForSending(req.getParameterMap());
        if (activeBean != null) {
            resp.setContentType("application/x-json");
            resp.getWriter().print(activeBean.toJSONObject());
            beanManager.onBeanSent(activeBean);
        } else {
            beanManager.onBeanTransferError();
            // throw new ServletException("JSONBeanServlet got no bean for sending");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req,
            HttpServletResponse resp)
            throws ServletException, IOException {

        JSONBean activeBean =
            beanManager.prepareBeanForReceiving(req.getParameterMap());

        if (activeBean != null) {
            String jsonText = req.getParameter(JSON_OBJ_PARAM);
            JSONObject jsonObj = null;
            try {
                jsonObj = new JSONObject(jsonText);
            } catch (JSONException e) {
                e.printStackTrace();
            }
            activeBean.fromJSONObj(jsonObj);

            beanManager.onBeanReceived(activeBean);

        } else {
            beanManager.onBeanTransferError();
            // throw new ServletException("JSONBeanServlet got no bean for receiving");
        }

    }

}

```

Для завершения описания серверной части следует напомнить о добавлении сервлета в `web.xml`.

``` xml

 <?xml version="1.0" encoding="UTF-8"?>
 <web-app xmlns="http://java.sun.com/xml/ns/j2ee"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee
    http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd"
    version="2.4">

    <display-name>SomeAplication</display-name>

    . . .

    <servlet>
        <description>JSON Beans Manage Servlet</description>
        <display-name>JSON Beans Servlet</display-name>
        <servlet-name>JSON Beans Servlet</servlet-name>
        <servlet-class>
            com.acme.json.FNJSONBeanServlet
        </servlet-class>
    </servlet>

    <servlet-mapping>
        <servlet-name>JSON Beans Servlet</servlet-name>
        <url-pattern>/jsonBean/*</url-pattern>
    </servlet-mapping>

    . . .

</web-app>

```

Клиентская часть состоит, собственно из [JSON-парсера-конструктора](http://www.json.org/json2.js) (да, всё это можно сделать через `eval()`, но предоставленный разработчиками код делает это, по их обещаниям, аккуратнее) и, в моём случае, класса, облегчающего работу с сервлетом. Класс использует немного модифицированную функцию `makeRequest` из [статьи о решениях JavaScript](?16-really-useful-javascript-solutions) (которую я обновлю до этой версии там сразу же после написания статьи) и обеспечивающие ООП функции `Class` \[[1](../16-useful-solutions-for-javascript#sol-1)\] и `createMethodReference` \[[2](../16-useful-solutions-for-javascript#sol-2)\] оттуда же.

``` javascript

var JSONManager = Class.extend({

    JSON_BEAN_SERVLET_PATH: "./jsonBean",
    JSON_BEAN_PARAM_NAME: "jsonBean",

    construct:
        function() {
            this._handlerFuncRef =
                createMethodReference(this, "_responseHandler");
        },

    requestJSONBean: function(handlerFunc, addParams) {
        makeRequest(this.JSON_BEAN_SERVLET_PATH, addParams,
                this._handlerFuncRef, handlerFunc);
    },

    sendJSONBean: function(jsonBean, addParams) {
        makeRequest(this.JSON_BEAN_SERVLET_PATH,
                this.JSON_BEAN_PARAM_NAME + "=" +
                JSON.stringify(jsonBean) + (addParams ?
                ("&" + addParams) : ""), null, true);
    },

    _responseHandler: function(http_request, handlerFunc) {
        handlerFunc(JSON.parse(http_request.responseText));
    }

});

```

Ну и в завершение -- пример использующего всё вышеприведённое кода:

``` javascript

    var alexanderJSON =
        {"personFirstName":    "Alexander",
         "personLastName":     "Makedonsky",
         "personAge":             35,
        };

    var jsonManager = new JSONManager();
    jsonManager.sendJSONBean(alexanderJSON, "source=SampleBean");

    var homerJSON = null;
    function onGotObject(http_request) {
        homerJSON = JSON.parse(http_request.responseText);
    }
    jsonManager.requestJSONBean(onGotObject, "source=SampleBean");

```

В качестве альтернативных идей -- методы `JSONBeanManager`‘а можно сделать статическими, а `JSONBean` научить приготавливать самого себя к отправке (инициировать данными) -- но при сложной структуре менеджера и требовании комплексной подготовки, когда `Bean` не может подготовить сам себя -- придётся от них отказаться. Однако, поскольку выбор `Bean`‘а по параметрам будет общим и для передачи и для приёма -- код выбора можно вынести и в отдельный метод.

### Заключение

Кажется, задача ознакомления выполнена и я со спокойной совестью, надеюсь, могу идти делать другие дела (я помню про обновление функции :) ). Если совесть должна быть неспокойна -- обязательно сообщайте, я стараюсь исправлять ошибки в своих статьях -- и даже те, которые, изредка, сам нахожу со временем. Приятной вам разработки.

### Пояснительные изображения

[![JSON Classes Structure]({{ get_figure(slug, 'json-package-structure-thumb.png') }})]({{ get_figure(slug, 'json-package-structure.png') }}) [![JSON Action Diagram]({{ get_figure(slug, 'json-action-diagram-thumb.png') }})]({{ get_figure(slug, 'json-action-diagram.png') }})
