---
layout: post.html
title: 10 полезных решений для разработчика под Android
datetime: 09 Jan 2011 19:48
tags: [ java, android ]
---

### Содержание

  1. Вступление
  2. Про адаптеры списков (`ListView`) с подразделами (для группировки элементов в списках)
  3. Про списки, содержащие какие-либо действия (элементы списка выполняют что-либо сложное или изменяют себя при выборе)
  4. Про принудительную инвалидацию видов в списках
  5. Про кэширование изображений для `ListView` (для списков с изображениями)
  6. Про адаптеры, итерирующиеся по курсорам (для поддержки постраничного вывода в списках)
  7. Про авторизацию через OAuth на Android
  8. Про использование `MediaPlayer` и буфферринг видео полученного по HTTP
  9. Про очереди из нескольких `AsyncTask` (для поочерёдного выполнения фоновых задач)
  10. Про изменение подсветки выбранного элемента в `ListView`
  11. Про добавление [QuickActions](http://www.londatiga.net/it/how-to-create-quickaction-dialog-in-android/) в проект
  12. Ещё три маленьких решения

### 1. Вступление

Летом прошлого (уже) года я загорелся желанием написать Android-клиент для веб-сервиса [vimeo](http://vimeo.com). Мне нравится этот сервис, и как по мне, было бы удобно следить за обновлениями в подписках на видео с коммуникатора.

Я задумывал [этот проект](http://code.google.com/p/vimeoid) для себя как учебный (в смысле, что учусь я), однако в результате получилось сделать вполне ощутимую часть (можно посмотреть [скриншоты того, что готово](http://code.google.com/p/vimeoid/wiki/Screenshots)), однако он пока что не закончен. Такой клиент делаю не я один, [свою версию](http://www.androlib.com/android.application.com-makotosan-vimeodroid-qmBCn.aspx) практически одновременно (он был первым) со мной начал делать [makotosan](http://vimeo.com/makotosan) и его версия пока что, похоже, тоже ещё делается).

В любом случае, в процессе написания проекта я получил некоторую базу знаний, которой и спешу поделиться. Не все темы экслюзивны, но некоторые рассматриваемые тонкости не раскрыты в интернете или закопаны довольно глубоко в его недрах. _Я буду дополнительно приводить примеры из искходных кодов vimeoid, это позволит вам подcмотреть как рассматриваемая тема работает в реальном времени_ (*NB*: некоторые ссылки ведут на конкретные строки в коде).

### 2. Списки с подразделами

Кроме обычного использования `ListView`, часто требуется сделать список, в котором элементы сгруппированы по нескольким разделам в таком виде: заголовок раздела, пункт, пункт, пункт, ..., заголовок раздела, пункт, пункт, ..., заголовок раздела, пункт, пункт, ... и т.д. На картинке это разделы "Statistics" и "Information".

(здесь и далее я буду использовать слово _пункт_ как аналог английскому _item_, чтобы отличать элемент списка, который может быть и заголовком раздела и пунктом, от пункта, обычного элемента, который не может быть заголовком)

![Список с разделами]({{ get_figure(slug, 'guest-channel.png') }})

Заголовки не должны реагировать на нажатия и выбор и должны иметь собственный вид. Этого можно достичь, переопределив кроме `getView` методы `getItemViewType`, `getViewTypeCount` и `isEnabled` адаптера этого списка и отнаследовав его, например, от `BaseAdapter`.

``` java

public class SectionedItemsAdapter extends BaseAdapter { . . .

```

 * Пример из vimeoid: [`SectionedActionsAdapter`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/adapter/SectionedActionsAdapter.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

Прежде всего заводятся константы, которые однозначно идентифицируют тип элемента, одна для заголовка, вторая для пункта (то есть типов может быть и больше двух, однако в таком случае лучше использовать `enum` с набором идентификаторов):

``` java

public static final int ITEM_VIEW_TYPE = 0; \\ пункт
public static final int SECTION_VIEW_TYPE = 1; \\ раздел

```

Потом константа, содержащая количество типов элементов (в нашем случае - два):

``` java

public static final int VIEW_TYPES_COUNT = SECTION_VIEW_TYPE + 1;

```

Адаптер будет содержать в себе информацию обо всех элементах, поэтому реализации `getCount`, `getItem` и `getItemId` зависят от вашей ситуации.

Метод `getItemViewType` должен возвращать константу соответствующую типу элемента по его позиции. Для неопределённого типа элемента в классе `Adapter` существует константа `IGNORE_ITEM_VIEW_TYPE`.

``` java

public int getItemViewType(int position) {
    if (. . .) return ITEM_VIEW_TYPE;
    if (. . .) return SECTION_VIEW_TYPE;
    return IGNORE_ITEM_VIEW_TYPE;
}

```

В моём случае я храню в адаптере список разделов, в которых содержатся им принадлежащие пункты. Таким образом у каждого раздела можно спросить сколько внутри него пунктов и засчёт этого узнать необходимый тип.

Этот метод теперь можно использовать в переопределении `getView`:

``` java

public View getView(int position, View convertView, ViewGroup parent) {
	  final int viewType = getItemViewType(position);
	  if (viewType == IGNORE_ITEM_VIEW_TYPE) throw new IllegalStateException("Failed to get object at position " + position);
	  if (viewType == SECTION_VIEW_TYPE) {
	      convertView = . . . // здесь можно через LayoutInflater получить Layout для заголовка раздела
	  } else if (viewType == ITEM_VIEW_TYPE) {
	      convertView = . . . // здесь можно через LayoutInflater получить Layout для пункта
	  }
	  return convertView;
}

```

Метод `isEnabled` должен возвращать `false` для элементов, на которые нельзя нажимать и на которые нельзя переходить курсором и `true` для остальных. Здесь снова поможет `getItemViewType`:

``` java

public boolean isEnabled(int position) {
    return getItemViewType(position) != SECTION_VIEW_TYPE };

```

Метод `getViewTypeCount` возвращает ту самую константу, количество возможных типов элементов:

``` java

public int getViewTypeCount() { return VIEW_TYPES_COUNT; }

```

Кстати, можно хранить ссылку на `LayoutInflater` в самом адаптере, а получать её от создавшей его активити через конструктор.

Это всё необходимое для реализации списка с разделами, если нужно - поглядывайте в пример, но прежде дам несколько пояснений.

В примере я использую структуры для хранения данных о разделах и пунктах. В структуре раздела хранится идентификатор раздела, его заголовок и структуры пунктов, содержащихся в нём. Структура пункта хранит указатель на родительскую структуру раздела, заголовок пункта, путь к иконке и обработчик нажатия на пункт (о нём в следующей главе). Конструкторы обоих структур доступны только в адаптерах:

 * Пример из vimeoid: [`LActionItem`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/adapter/LActionItem.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

Таким образом я упростил добавление групп и пунктов в список. Адаптер имеет методы:

``` java

public int addSection(String title);
public LActionItem addItem(int section, int icon, String title);

```

Метод `addSection` возвращает идентификатор группы, который затем можно использовать для добавления пунктов в эту группу:

``` java

final int suitsSection = adapter.addSection("Suits");
adapter.addItem(suitsSection, R.drawable.heart, "Hearts");
adapter.addItem(suitsSection, R.drawable.diamond, "Diamonds");
adapter.addItem(suitsSection, R.drawable.spade, "Spades");
adapter.addItem(suitsSection, R.drawable.cross, "Crosses");
final int figuresSection = adapter.addSection("Figures");
adapter.addItem(figuresSection, R.drawable.king, "King");
adapter.addItem(figuresSection, R.drawable.queen, "Queen");
. . .

```

### 3. Списки с реагирующими элементами

Иногда нужно, чтобы при нажатии на элементе списка он изменил своё состояние и/или перешёл на другую активити. Например, элемент "зафолловить" в списке с действиями над аккаунтом в твиттере может содержать иконку с минусом, если вы ещё не фолловили этого человека и менять иконку на плюс после нажатия и пришедшего подтверждения о фолловинге. Можно обрабатывать выбранный элемент в текущей `ListActivity` и в зависимости от позиции предпринимать решение, но если список содержится где-то внутри обычной `Activity`, то возможно легче обрабатывать выбор в адаптере.

 * Пример из vimeoid: [`SectionedActionsAdapter`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/adapter/SectionedActionsAdapter.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Использует: [`LActionItem`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/adapter/LActionItem.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Используется в: [`SingleItemActivity_`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/base/SingleItemActivity_.java?r=85e18485bdda1c526141170f67e65f4e00202f34#49)

Если вы согласны с этим, ваш адаптер может имплементировать интерфейс `OnItemClickListener`:

``` java

public class ActionsAdapter extends . . . implements OnItemClickListener

```

А в использующей его активити можно сделать:

``` java

final ListView actionsList = (ListView)findViewById(R.id.actionsList);
final SectionedActionsAdapter actionsAdapter = new ActionsAdapter(. . .);
. . . // заполнить адаптер значениями
actionsList.setAdapter(actionsAdapter);
actionsList.setOnItemClickListener(actionsAdapter);

```

В моём случае за пункты в каждом разделе выступают какие-то действия - переходы на активити либо изменения вида пункта после запроса к серверу. Поэтому я предпочёл сделать структуры с публично доступными свойствами для разделов и пунктов, при этом структуры пунктов содержат обработчик `OnClick` который принимает `View` на котором произошёл выбор, поэтому можно изменять `View` прямо из них. Благодаря этому в адаптере можно просто передать действие обработчику:

``` java

public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
    final LActionItem item = (LActionItem) getItem(position);
    if (item.onClick != null) item.onClick(view);
}

```

Используя описанный выше метод `addItem` можно устанавливать обработчик:

``` java

final LActionItem heartsItem = adapter.addItem(suitsSection, R.drawable.heart, "Hearts");
heartsItem.onClick = new OnClickListener() { public void onClick(View view) { . . . } };

```

### 4. Принудительная инвалидация видов в списках

`ListView` в Android, как известно, устроены с небольшой хитростью, эта хитрость - [_ListView Recycler_](http://android.amberfog.com/?p=296). Приницип _Recycler_'а, если кратко, состоит в том, что если в списке элементов больше, чем вмещается на экран, при прокручивании списка виды новых элементы не создаются, а переиспользуются виды старых - на этом приниципе работают имплементации `getView` в адаптерах.

Если в какой-то момент требуется обновить (инвалидировать) конкретный известный вид элемента (или даже его дочерний вид) списка в то время, когда он видим на экране, можно вызвать `ListView.invalidate()` или `Adapter.notifyDataSetChanged()`, но иногда эти методы нерационально обновляют и соседние виды, а то и вообще все видимые (особенно если layout [построен неправильно](http://www.curious-creature.org/2009/02/22/android-layout-tricks-1/)). Есть способ получить текущий вид элемента списка используя метод `ListView.getChildAt(position)`. Однако `position` в данном случае это не индекс элемента в списке, как можно было бы ожидать, а индекс относительно видимых на экране видов. Поэтому полезными будут такие методы:

``` java

public static View getItemViewIfVisible(AdapterView<?> holder, int itemPos) {
	  int firstPosition = holder.getFirstVisiblePosition();
	  int wantedChild = itemPos - firstPosition;
	  if (wantedChild < 0 || wantedChild >= holder.getChildCount()) return null;
	 return holder.getChildAt(wantedChild);
}

public static void invalidateByPos(AdapterView<?> parent, int position) {
    final View itemView = getItemViewIfVisible(parent, position);
    if (itemView != null) itemView.invalidate();
}

```

`invalidateByPos` обновляет вид только если он видим на экране (насильно вызывая `getView` адаптера), а если элемент не видим - `getView` адаптера будет вызван автоматически когда этот вид появится в области видимости при прокрутке списка. Чтобы обновить некий дочерний вид элемента, вы можете использовать метод `getViewIsVisible`, он вернёт вид элемента из которого можно получить доступ к его дочерним видам и `null`, если вид не видим пользователю и в обновлении нет необходимости.

 * Методы описаны в классе: [`Utils`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/util/Utils.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

### 5. Про кэширование изображений для списков

![Список с картинками]({{ get_figure(slug, 'guest-videos.png') }})

Если вы создаёте список `ListView`, содержащий изображения загружаемые из сети, эта глава для вас. Неразумно бы было при каждом вызове `getView` в адаптере получать изображения по URL заново - естественно лучше бы было их а) кэшировать б) запрашивать только тогда, когда вид с изображением видим пользователю. На данный момент эта задача так часто вставала перед программистами на Android, что уже существует [множество её решений](http://stackoverflow.com/questions/541966/android-how-do-i-do-a-lazy-load-of-images-in-listview).

Мой вариант оттуда же, это решение [Фёдора Власова](http://stackoverflow.com/questions/541966/android-how-do-i-do-a-lazy-load-of-images-in-listview/3068012#3068012), исправленное под мои нужды. Во-первых, я сделал каталог для хранения кэшированных изображений статическим - то есть он создаётся единожды за время жизни приложения и стабильно очищается при вызове `clearCache` (этот метод полезно вызывать в `onDestroy()` у активити, использующей `ImageLoader` или в `finalize()` у использующего его адаптера), немного изменил способ создания этого каталога (см. `Utils.createCacheDir()`). Во-вторых, в конструктор можно передать идентификаторы изображений, которые будут показаны на месте картинки в процессе её загрузки и/или если загрузить её не удалось. В-третьих ещё пара мелких изменений. Вообще, этот класс можно было бы и сделать синглтоном, изменяя настройки перед использованием, но это уже на ваше усмотрение. В моём случае по одному его экземпляру создаётся для каждой запущенной `ListActivity` и передаётся адаптерам каждого нуждающегося `ListView` (или создаётся в самих адаптерах, если `ListView` находится внутри обычной `Activity`). Основной метод - `displayImage(String url, ImageView view)`, его определение говорит само за себя.

 * Исходник из vimeoid: [`ImageLoader`](http://code.google.com/p/vimeoid/source/browse/apk/src/com/fedorvlasov/lazylist/ImageLoader.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Использует методы из: [`Utils`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/util/Utils.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

### 6. Адаптеры, итерирующиеся по курсорам

Эта глава касается постраничного вывода в `ListView`. То есть, пользователь видит первые `n` элементов, прокручивает список до `n`-ного элемента и только после этого выполняется запрос на следующие `n` элементов к базе данных или к серверу. Затем пользователь пролистывает список до элемента `2n` и мы запрашиваем следующую пачку размером `n` и т.д. В _vimeoid_ я делаю следующий запрос при клике по `footerView` с надписью "Загрузить ещё..." у списка: не автоматически, но техника примерно та же.

 * Загрузка по клику на `footerView`: [`ItemsListActivity_`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/base/ItemsListActivity_.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Реализация для гостя: [`ItemsListActivity`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/guest/ItemsListActivity.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Реализация для зарегистрированного пользователя: [`ItemsListActivity`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/user/ItemsListActivity.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

Здесь более сложная иерархия классов, загрузка каждой страницы осуществляется через специальный `AsyncTask`, который после фонового вызова Vimeo API сообщает вызвавшему активити, остались ли ещё элементы и не последняя ли это страница, а активити обновляет свои виды в соответствии с этими данными.

 * Адаптер, содержащий набор курсоров: [`EasyCursorsAdapter`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/adapter/EasyCursorsAdapter.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

Для того, чтобы обеспечить постраничный вывод, можно просто хранить список из контейнеров для страниц (например, курсоров) в адаптере, а в `getView()`, если запрошен один из последних элементов, запускать запрос на следующую страницу (предпочтительно - `AsyncTask`), который при получении нового контейнера добавит его в адаптер и адаптер сможет вызвать `notifyDataSetChanged()`. Примерно так:

``` java

private final Page[] pages = new Page[MAX_PAGES_COUNT];

public View getView(final int position, View convertView, ViewGroup parent) {

    if (!waitingNextPage &&
        (pages.length < MAX_PAGES_COUNT) &&
        (position >= ((pages.length * PER_PAGE) - 2))) {

        final AsyncTask<Integer, . . .> nextPageTask = . . .;
        nextPageTask.execute(pages.length);
        // nextPageTask вызывает addSource, когда получает новую страницу

        waitingNextPage = true;
    }

    . . .

}

public void addSource(Page page) {
    if (pages.length >= MAX_PAGES_COUNT) return;
    pages[pages.length] = page;
    waitingNextPage = false;
    notifyDataSetChanged();
}

```

`EasyCursorsAdapter` - хороший пример, где в качестве аналога `Page` выступает `Cursor`. Наверняка есть и альтернативные решения, буду рад если их упомянут в комментариях.

### 7. Авторизация через OAuth на Android

Если вы пишете клиент для какого-либо сложного веб-сервиса - вы сталкиваетесь с проблемой авторизации, в подавляющем количестве веб-сервисов для её реализации ныне используется [OAuth](http://en.wikipedia.org/wiki/OAuth) и Vimeo как раз из числа таких.

Не стоит писать реализацию самому, это несколько неблагодарное дело, благо уже есть отличная библиотека [signpost](http://code.google.com/p/oauth-signpost/) и лучших альтернатив, насколько я знаю, пока нет.

 * Пример из vimeoid: [`VimeoApi`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/connection/VimeoApi.java?r=85e18485bdda1c526141170f67e65f4e00202f34#101)
 * Использует signpost через: [`JsonOverHttp`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/connection/JsonOverHttp.java?r=85e18485bdda1c526141170f67e65f4e00202f34#164)
 * Активити, которое получает токен пользователя: [`ReceiveCredentials`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/ReceiveCredentials.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Его описание в манифесте: [`AndroidManifest.xml`](http://code.google.com/p/vimeoid/source/browse/apk/AndroidManifest.xml?r=85e18485bdda1c526141170f67e65f4e00202f34#22)

Для начала нужно получить уникальный ключ для вашего приложения от веб-сервиса и указать веб-сервису URL, на который будет возвращатся пользователя при успешной авторизации (напр., `vimeoid://oauth.done`) (но в случае Android его передают при запросе к `/request_token`). Обычно это делается через веб-интерфейс самого сервиса.

Алгоритм первой авторизации на Android следующий:

 1. Указать signpost где у сервиса находятся точки входа в OAuth
 1. Запросом к `/request_token` получить пару токен/секрет приложения для неавторизированных запросов по этому ключу (колбэк-URL `vimeoid://oauth.done` передают здесь): `provider.retrieveRequestToken(Uri callbackUri)`. *NB:* `retrieveRequestToken` возвращает не токен, а сразу `Uri`, тот самый `authUri` по которому надо обратиться в следующем пункте
 1. Запустить активити браузера, обратиться к `/authorize`, передав токен приложения и, если необходимо, добавив дополнительные параметры о необходимых правах: `startActivity(new Intent(Intent.ACTION_VIEW, authUri + ...))`
 1. Пользователь увидит страницу в стиле "Разрешить этому приложению доступ к вашему аккаунту?" (если он разлогинен в сервисе, ему предложат залогиниться). Если он разрешает доступ, браузер перенаправляется по адресу колбэка `vimeoid://oauth.done?...`, но так как в вашем `AndroidManifest.xml` для перехвата таких URL описано специальное активити, Android возвращает пользователя к вашему приложению, открывая это самое активити - `ReceiveCredentials`
 1. В активити `ReceiveCredentials` вы получаете токен пользователя в параметрах `Uri uri = getIntent().getData()`, теперь по этому токену нужно получить секрет через запрос к `/access_token`: `provider.retrieveAccessToken(Uri uri)`
 1. Теперь можно сохранить токен и секрет пользователя, например, в приватных `SharedPreferences`: `consumer.getToken()`, `consumer.getTokenSecret()`

После этого вы можете подписывать каждый запрос к API веб-сервиса полученными токенами: `consumer.sign(Object request)`. Если ваше приложение было перезапущено, перед всеми запросами можно проверить, нет ли токенов в `SharedPreferences`, если есть - напомнить о них `signpost`'у: `consumer.setTokenWithSecret(String token, String secret)`, а если нет - запросить секрет пользователя заново (или обновить токены, если веб-сервис это позволяет).

Важное замечание: на Android signpost работает только с использованием `CommonsHttpOAuthConsumer`/`CommonsHttpOAuthProvider`. Классы `DefaultOAuth*` не работают.

### 8. Медиа-плеер и буфферинг видео по HTTP

[`MediaPlayer`](http://developer.android.com/reference/android/media/MediaPlayer.html) как оказалось, очень трудно заставить работать так, как хочется, в случае проигрывания видео. Чтобы получить видео мне нужно было выполнить необычный HTTP-запрос со специальными заголовками, поэтому получение потока и его буфферизирование пришлось писать вручную. Потоковое воспроизведение по аналогу [примеров для аудио-файлов](http://blog.pocketjourney.com/2009/12/27/android-streaming-mediaplayer-tutorial-updated-to-v1-5-cupcake/) у меня не вышло, поэтому пока что я просто загружаю видео полностью и начинаю проигрывание, когда оно уже загрузилось (если на карте не хватит места, я предупреждаю пользователя). При закрытии плеера или неудачном проигрывании я очищаю кэш.

Ещё, поведение `VideoView`/`SurfaceView` при переключении видов в пределе одного лэйаута тоже работает очень неоднозначно (чёрный экран через раз), поэтому пришлось банально оставлять в лэйауте один-единственный `VideoView` и показывать `ProgressDialog` поверх него, пока видео загружается. Опять же, если вы знаете что-то про потоковое воспроизведение видео средствами `MediaPlayer` (или о получении чанков вручную), пишите в комментариях.

Поэтому, если в вашем случае вам хватит вызова `MediaPlayer.setDataSource(Uri uri)`, можете пропустить следующий абзац, большего в ней не рассказывается.

Если же вам тоже пришлось получать поток вручную, я обращу ваше внимание на пару моментов, в остальном просто продемонстрирую код, он должен рассказать всё сам:

  * Пример из vimeoid: [`VimeoVideoPlayingTask`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/media/VimeoVideoPlayingTask.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
  * Вызывается из активити: [`Player`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/Player.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
  * Лэйаут: [`player.xml`](http://code.google.com/p/vimeoid/source/browse/apk/res/layout/player.xml?r=85e18485bdda1c526141170f67e65f4e00202f34)

Загружать поток лучше используя `AsyncTask`. Я просто агрегирую `MediaPlayer` внутри `...PlayingTask` для удобства, вы можете выбрать любой другой способ, но получать поток определённо лучше через `AsyncTask`. При этом, в методе `onPreExecute` можно подготовить плеер и настроить его, в `doInBackground` получить поток видео и вернуть этот поток в `onPostExecute`, в котором и запустить проигрывание. Опять же, удобно показывать процентный прогресс загрузки, потому что в `doInBackground` известно количество полученных данных.

Если при загрузке потока возникает исключение, сообщение о нём приходится показывать через `runOnUiThread`, потому что выполнение задачи было прервано.

Выполнение `getWindow().setFormat(PixelFormat.TRANSPARENT);` предназначено, чтобы отображённые поверх плеера виды не оставались поверх него после скрытия. Хотя если нужно использовать `ViewSwitcher`, это всё равно не помогает.

Код получения потока по URL примерно таков:

``` java

public static InputStream getVideoStream(long videoId)
       throws FailedToGetVideoStreamException, VideoLinkRequestException {
    try {
        final HttpClient client = new DefaultHttpClient();
        . . .
        final HttpResponse response = client.execute(request);
        if ((response == null) || (response.getEntity() == null))
            throw new FailedToGetVideoStreamException("Failed to get video stream");
        lastContentLength = response.getEntity().getContentLength();
        return response.getEntity().getContent();
    } catch (URISyntaxException use) {
        throw new VideoLinkRequestException("URI creation failed : " + use.getLocalizedMessage());
    } catch (ClientProtocolException cpe) {
        throw new VideoLinkRequestException("Client call failed : " + cpe.getLocalizedMessage());
    } catch (IOException ioe) {
        throw new VideoLinkRequestException("Connection failed : " + ioe.getLocalizedMessage());
    }
}

```

### 9. Очереди из AsyncTask

Если вам часто приходится выполнять по нескольку фоновых задач поочерёдно (когда завершилось одно - запускать следующее), этот вольный паттерн, скрывающий в себе переходы по связанному списку, вам подойдёт. Например, вам может понадобиться выполнить при загрузке Activity сразу несколько поочерёдных запросов к API некоего веб-сервиса или к базе данных. Главное, чтобы типы параметров и результата у всех этих задач всегда были одинаковыми.

Вот интерфейс задачи, которая знает что у неё есть следующая задача:

``` java

public interface HasNextTask<Params> {
    public int getId();
    void setNextTask(HasNextTask<Params> task);
    public HasNextTask<Parames> getNextTask();
    public AsyncTask<?, ?, ?> execute(Params... params);
                         // совпадение с AsyncTask<Params, ...>
}

```

Интерфейс, который следит за всеми моментами, когда задачи удачно или неудачно выполняются:

``` java

public interface PerformHandler<Params, Result> {
    public void onPerfomed(int taskId, Result result, HasNextTask<Params> nextTask);
    public void onError(Exception e, String description);
}

```

Реализация интерфейса `HasNextTask`. То что представлено многоточиями, можно вынести в дочерний класс или сделать сам класс абстрактным, чтобы методы `doInBackground`/`onPostExecute` реализовывались прямо в `createTask` очереди:

``` java

public class TaskInQueue<Params, Result> extends AsyncTask<Params, Void, Result>
                                         implements HasNextTask<Params> {

    private final int taskId;
    private HasNextTask<Params> nextTask = null;
    private final PerformHandler<Params, Result> listener;

    public TaskInQueue(PerformHandler<Params, Result> listener, int taskId) {
        this.taskId = taskId;
        this.listener = listener;
    }

    @Override
    public Result doInBackground(Params... params) { . . . /* выполнение задачи */ }

    @Override
    protected void onPostExecute(Result result) {
        . . . // обработка результата, если нужно
        listener.onPerformed(taskId, result, nextTask);
    }

    @Override public int getId() { return taskId; }

    @Override
    public void setNextTask(HasNextTask<Params> nextTask) {
        if (this.nextTask != null)
            throw new IllegalStateException("Next task is already set");
        this.nextTask = nextTask;
    }

    @Override
    public HasNextTask<Params> getNextTask() { return nextTask; };

}

```

Ну и самое главное, реализация очереди:

``` java

public abstract class TasksQueue<Params, Result>
                implements PerformHandler<Params, Result>, Runnable {

    public static final String TAG = "TasksQueue";

    private HasNextTask<Params> firstTask = null;
    private HasNextTask<Params> lastTask = null;
    private Map<Integer, Params> tasksParams = null;
    private int currentTask = -1;
    private boolean running = false; // сейчас выполняется одна из задач
    private boolean started = false; // очередь запущена
    private int size = 0;

    protected HasNextTask<Params> createTask(int taskId) { // можно переопределить
        return new TaskInQueue<Params, Result>(this, taskId);
    }

    @Override
    public HasNextTask<Params> add(int taskId, Params params) {
        Log.d(TAG, "Adding task " + taskId);
        final HasNextTask<Params> = createTask(taskId);
        if (isEmpty()) {
            firstTask = task;
            lastTask = task;
            tasksParams = new HashMap<Integer, Params>();
        } else {
            lastTask.setNextTask(task);
            lastTask = task;
        }
        tasksParams.put(task.getId(), params);
        size += 1;
        return task;
    }

    @Override
    public void run() {
        Log.d(TAG, "Running first task");
        if (!isEmpty())
            try {
                started = true;
                execute(firstTask);
            } catch (Exception e) {
                onError(e, e.getLocalizedMessage());
                finish();
            }
        else throw new IllegalStateException("Queue is empty");
    }

    @Override
    public void onPerfomed(int taskId, Result result, HasNextTask<Params> nextTask) {
    	  Log.d(TAG, "Task " + taskId + " performed");
        if (taskId != currentTask)
            throw new IllegalStateException("Tasks queue desynchronized");
        running = false;
        try {
            if (nextTask != null) {
                execute(nextTask);
            } else finish();
        } catch (Exception e) {
            onError(e, "Error while executing task " +
                       ((nextTask != null) ? nextTask.getId() : taskId));
            finish();
        }
    }

    protected void execute(HasNextTask<Result> task) throws Exception {
    	  Log.d(TAG, "Trying to run task " + task.getId());
        if (running) throw new IllegalStateException("Tasks queue desynchronized");
        currentTask = task.getId();
        running = true;
        Log.d(TAG, "Running task " + task.getId());
        task.execute(tasksParams.get(task.getId())).get(); // wait for result
    }

    protected void finish() {
        firstTask = null;
        lastTask = null;
        if (tasksParams != null) tasksParams.clear();
        tasksParams = null;
        currentTask = -1;
        running = false;
        started = false;
        size = 0;
    }

    public boolean isEmpty() { return (firstTask == null); }

    public boolean started() { return started; }

    public boolean running() { return running; }

    public int size() { return size; }

}

```

Теперь в ваших активити в любой момент можно с лёгкостью создать очередь фоновых задач:

``` java

protected final TasksQueue secondaryTasks;

private final int TASK_1 = 0;
private final int TASK_2 = 1;
private final int TASK_3 = 2;

public ...Activity() { // конструктор

    secondaryTasks = new TasksQueue<..., ...>() {

        // здесь можно переопределить createTask

        @Override public void onPerfomed(int taskId, ... result) throws JSONException {
            super.onPerfomed(taskId, result);
            onSecondaryTaskPerfomed(taskId, result);
        }

        @Override public void onError(Exception e, String message) {
            Log.e(TAG, message + " / " + e.getLocalizedMessage());
            Dialogs.makeExceptionToast(ItemsListActivity.this, message, e);
        }

    };

    secondaryTasks.add(TASK_1, ...);
    secondaryTasks.add(TASK_2, ...);
    secondaryTasks.add(TASK_3, ...);

}

protected void someMethod() {
    . . .
    if (!secondaryTasks.isEmpty()) secondaryTasks.run();
    . . .
}

protected void onSecondaryTaskPerfomed(int taskId, ... result) {
    switch (taskId) {
        case TASK_1: . . .
        case TASK_2: . . .
        case TASK_3: . . .
        . . .
    }
}

```

Кстати, благодаря интерфейсу `Runnable` такие очереди можно запускать в отдельном потоке:

``` java

new Thread(secondaryTasks, "Tasks Queue").start();

```

 * Очередь в vimeoid: [`ApiTasksQueue`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/user/ApiTasksQueue.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Создаётся в: [`SingleItemActivity`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/user/SingleItemActivity.java?r=85e18485bdda1c526141170f67e65f4e00202f34#49)
 * Инициализируется задачами в: [`UserActivity`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/user/item/UserActivity.java?r=85e18485bdda1c526141170f67e65f4e00202f34#122)
 * Обработка выполненных задач в: [`UserActivity`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/user/item/UserActivity.java?r=85e18485bdda1c526141170f67e65f4e00202f34#301)

### 10. Подсветка выбора в ListView

![Выбранная строка в списке]({{ get_figure(slug, 'user-video.png') }})

На картинке видно синюю полосу, это кастомная подсветка выбранного элемента, она имеет четыре состояния - нажатая, имеющая фокус, запрещённая и анимация перехода от нажатой в зажатую для долгого тапа. Первые три и зажатое состояние - это так называемые `9-patch`, вы наверняка [о них слышали](http://developer.android.com/guide/developing/tools/draw9patch.html), анимация - `xml`-файл анимации.

Для того чтобы описать состояния для подсветки выбора, укажите в лэйауте `android:listSelector="@drawable/selector_bg"` для вашего `ListView`.

`selector_bg.xml` - это ещё один `xml`-файл, набор правил о том как изменяется подстветка в зависимости от состояний. Система проходит по каждому правилу и как только первое правило совпало, оно выполняется, а следующие игнорируются. Алгоритм прост, но выстроить правила в верном порядке не всегда выходит сразу. Смотрите примеры:

 * Описание: [`selector_bg.xml`](http://code.google.com/p/vimeoid/source/browse/apk/res/drawable/selector_bg.xml?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Анимация: [`selector_bg_transition.xml`](http://code.google.com/p/vimeoid/source/browse/apk/res/drawable/selector_bg_transition.xml?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Объявлен в: [`generic_list.xml`](http://code.google.com/p/vimeoid/source/browse/apk/res/layout/generic_list.xml?r=85e18485bdda1c526141170f67e65f4e00202f34#16)

![редактор 9-patch]({{ get_figure(slug, 'draw9patch-norm.png') }})

С 9-patch тоже есть хитрости, чуть что не так в лэйауте - и они разъезжаются и весь список разъезжается тоже. Главное правило - проверить прежде описание `ListView`, убедитесь что `layout_width` и `layout_height` установлены в `fill_parent` и кроме того перепроверьте элементы выше по иерархии. Затем, если не помогло, можно исправлять 9-patch. Тонкие чёрные линии сверху и слева обозначают области картинки, которые будут растянуты если контент не влез в картинку. Тонкие чёрные линии (необязательные) справа и снизу обозначают области в которые сам контент будет вписан. Подобрать нужные позиции тоже получается не сразу, приходится экспериментировать. Даже не думайте создавать 9-patch без редактора из коробки, это лишний вынос мозга - в редакторе подсвечиваются области для контента и ошибки, и даже когда всё вроде верно, не всегда раскладка воспринимается инфлейтером как ожидалось.

![Запрещённое состояние]({{ get_figure(slug, 'selector_bg_disabled.9.png') }}) ![Cостояние фокуса]({{ get_figure(slug, 'selector_bg_focus.9.png') }}) ![Нажатое состояние]({{ get_figure(slug, 'selector_bg_pressed.9.png') }}) ![Зажатое состояние]({{ get_figure(slug, 'selector_bg_longpress.9.png') }})

### 11. Добавление QuickActions

![Пример QuickActions]({{ get_figure(slug, 'user-videos.png') }})

[QuickActions](http://www.londatiga.net/it/how-to-create-quickaction-dialog-in-android/) - небольшая библиотека для всплывающих диалогов с действиями, таких как на рисунке (и не только таких, потому что их дизайн можно менять свободно). Они стали новым популярным веянием при появлении официального твиттер-клиента. Должны быть и другие имплементации, в _vimeoid_ я использую эту, и её тоже немного подправил для своих нужд.

Для того, чтобы отобразить такой диалог вместо контекстного меню при долгом тапе на элементе в списке, достаточно переопределить метод `onCreateContextMenu` в `ListActivity` таким образом:

``` java

public void onCreateContextMenu(ContextMenu menu, View v, ContextMenuInfo menuInfo) {
    . . .
    final AdapterView.AdapterContextMenuInfo info = extractMenuInfo(menuInfo);
    final QuickAction quickAction =
          createQuickActions(info.position, getItem(info.position), info.targetView);
    if (quickAction != null) quickAction.show();
}

protected QuickAction createQuickActions(final int position, final ... item, View view) {
    QuickAction qa = new QuickAction(view);
    qa.addActionItem(getString(R.string...),
                     getResources().getDrawable(R.drawable...),
            new QActionClickListener() {
                @Override public void onClick(View v, QActionItem item) {
                    . . .
                }
            });
    . . .
    return qa;
}

```

 * Каталог, содержащий модифицированную библиотеку [`lib-qactions`](http://code.google.com/p/vimeoid/source/browse/lib-qactions?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Используется в: [`VideosActivity`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/user/list/VideosActivity.java?r=85e18485bdda1c526141170f67e65f4e00202f34#113)

О добавлении внешней библиотеки в проект Eclipse рассказано в [этой статье](http://developer.android.com/guide/developing/eclipse-adt.html#libraryProject). Если кратко, достаточно создать для библиотеки отдельный Android-проект с исходниками, установить чекбокс `isLibrary` в разделе `Android` в свойствах этого проекта, а в основном проекте добавить проект с библиотекой пунктом `Library` -> `Add` из того же раздела. При этом `R`-файл из проекта с библиотекой будет добавлен в основной проект.

### 12. Ещё три маленьких решения

#### 12а. Единое место для вызова различных активити

Если в вашем приложении много различных активити и они вызываются схожим образом, возможно будет удобно перенести их вызовы включая заполнение `Extras` в отдельный класс:

 * Пример из vimeoid: [`Invoke`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/util/Invoke.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

#### 12б. Про плэйсхолдеры в локализации

Возможно это очевидно, но в строках из `strings.xml` можно использовать плейсходеры для того, чтобы подставлять какие-то независимые от локали значения внутрь строк, например: `<string name="image_info">Image size: {width}x{height}</string>`. В этом поможет функция `format`, которую можно вызвать так: `format(getString(R.string.image_info), "width", String.valueOf(600), "height", String.valueOf(800))`:

``` java

public static String format(String source, String... params) {
    String result = source;
    int pos = 0;
    while (pos < params.length) {
        result = result.replaceAll("\\{" + params[pos++] + "\\}", params[pos++]);
    }
    return result;
}

```

**Upd.** Оказалось, как я и думал, это велосипед: Есть стандартная функция [`getString(int resId, Object... formatArgs)`](http://developer.android.com/intl/de/reference/android/content/Context.html#getString%28int,%20java.lang.Object...%29). Спасибо [zochek](http://zochek.habrahabr.ru/).

#### 12в. Про некорректные лэйауты

Обязательно прочитайте эти статьи, инфлэйтер в андроиде действительно очень чувствителен к сложным структурам и если вы пишете сложное приложение, лэйауты рано или поздно придётся оптимизировать:

 * [Layout Tricks #1](http://www.curious-creature.org/2009/02/22/android-layout-tricks-1/)
 * [Layout Tricks #2](http://www.curious-creature.org/2009/02/25/android-layout-trick-2-include-to-reuse/)
 * [Layout Tricks #3](http://www.curious-creature.org/2009/03/01/android-layout-tricks-3-optimize-part-1/)
 * [Layout Tricks #4](http://www.curious-creature.org/2009/03/16/android-layout-tricks-4-optimize-part-2/)
 * [Speed up your Android UI](http://www.curious-creature.org/2009/03/04/speed-up-your-android-ui/)

Мои часто перерендеривающиеся лэйауты в один момент потерпели крах и `getView` адаптера стал вызываться практически каждую секунду (и до сих пор бывает такое, но уже сильно реже). После замены многих вложенных сложноструктурированных `LinearLayout`ов на менее вложенные и элегантные `RelativeLayout`, инфлэйтеру стало явно легче и мне самому тоже, потому что иерархия стала короче и делать мелкие изменения стало проще. Я их ещё не везде успел подменить, но теперь отнощусь к лэйаутам внимательнее. Также следите за тем, чтобы `width/height=wrap_content` использовался по возможности только для простых элементов, использование `wrap_content` в качестве параметров ширины/высоты `LinearLayout` и прочих сложных видов может привести к сложным последствиям. Может и не привести, но кто предупреждён...
