---
layout: post.html
title: На клиенте! Получить XML! Получить XSL! Сделать XHTML! Марш!
datetime: 18 Sep 2009 11:41
tags: [ xml, xslt, javascript ]
---

**(X-Task: "On your Client! Get XML! Get XSL! Do XHTML! Go!")**

### Вступление

Статья рассматривает преобразование XML в XHTML посредством XSLT на клиенте средствами JavaScript. К примеру, у вас есть какие-либо данные в виде XML, а вам требуется по какому-либо действию клиента (по клику на ссылке), оформить их в [X]HTML и динамически вставить в страницу. Это не так сложно, но по пути, как оказалось, встречается несколько подводных камней — в основном, относительно кросс-браузерности этого подхода и малой освещённости процесса в сети. _Генерация XHTML-страниц средствами браузера (прямой запрос на XML файл, содержащий информацию о стиле) — это другая тема, она намного проще, и здесь затронута не будет._

Задача будет рассмотрена на банальном примере личного сайта. Дано: Файл с контактными данными (XML), некая главная страница (XHTML) и пять браузеров: Firefox 3, Opera 9.5, IE7, Safari 3, Google Chrome. На главной странице есть ссылка, при нажатии которой контактные данные преобразуются в несортированный список (UL) и отображаются в специально выделенной области прямо на этой странице. Это реальный рабочий пример, который я сейчас использую для создания своего сайта (ещё не выложенного).

### XML

Контактные данные, при их большом количестве, можно сгруппировать, поэтому XML-схема построена с учётом группировки элементов. Группа имеет краткое имя (`shortname`) для создания `id` у списка (возможно, потребуется оформить каждую группу по-особому) и, собственно, имя группы. XML-файл может содержать `contact`-ноды и вне групп, но в данном примере в этом нет необходимости. Все контакты имеют тип (`type`) для создания корректных ссылок в будущем (это мы также опустим). С остальным, вроде бы, всё понятно:

![XML Schema Example]({{ get_figure(slug, 'xml-schema-example.jpg') }})

Структура довольно-таки проста, поэтому приведу сразу пример файла (любое сходство с реальными данными какого-либо индивидуума полностью случайно и приведено не намеренно):

``` xml

<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="./contacts.xsl"?>
<contacts
    xmlns="http://any-developer.name"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://any-developer.name ./contacts.xsd">
    <group shortname="messengers">
        <name>Messengers</name>
        <contact type="skype">
            <id>any.developer</id>
        </contact>
        <contact type="jabber">
            <id>any.developer@jabber.org</id>
            <name>ulric.wilfred</name>
        </contact>
        <contact type="gtalk">
            <id>any.developer</id>
        </contact>
        <contact type="yahoo">
            <id>any.developer</id>
        </contact>
        <contact type="icq">
            <id>7484939304033345544</id>
            <name>any.developer</name>
        </contact>
    </group>
    <group shortname="email">
        <name>E-Mail</name>
        <contact type="gmail">
            <id>any.developer</id>
        </contact>
        <contact type="yahoo-mail">
            <id>any.developer</id>
        </contact>
    </group>
</contacts>

```

### XSL

Стиль генерирует XHTML-код, в виде списка UL, состоящего из негруппированных контактов и вложенных списков для групп. Поскольку результат вывода именно __X__HTML, требования к оформлению результата несколько строже, чем если бы это был обычный HTML. Поэтому следует обратить внимание на следующие моменты:

* **Важно:** В результате преобразования должен получаться файл с одной и только одной корневой нодой, иначе Safari и Google Chrome (_Читай:_ WebKit) не смогут добавить результирующий элемент в документ. Это довольно разумно, поскольку для всех XML объектов (результат в виде XHTML из их числа) есть правило: корневой элемент должен быть только один (_There can be the only one_).
* **Важно:** В качестве `xsl:output method` должен быть указан либо `xml` либо `html` (однако, в последнем случае, при использовании пронстранств имён, таковые будут потеряны). Некоторые ставят это значение в `xhtml` и в результате получают некорректную обработку или ошибки на клиенте — пока этого метода не введено и не следует его использовать. Для этого есть `media-type`.
* Код генерируется без заголовков XML: `omit-xml-declaration` установлен в `yes` и `xmlns` не указывается, иначе в результате получится недоXHTML-файл с XML-заголовком, не содержащий `html`, `head` и `body`. Генерация `DOCTYPE` (`doctype-system`, `doctype-public`) также отключена.

Исходник:

``` xml

<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:c="http://any-developer.name" exclude-result-prefixes="c">
<!--    xmlns="http://www.w3.org/1999/xhtml" -->

<xsl:output method="xml"
            encoding="utf-8"
            standalone="yes"
            indent="yes"
            omit-xml-declaration="yes"
            media-type="text/xhtml"/>
        <!--
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
            doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
        -->

<xsl:template name="contact">
    <li><a href="javascript:alert('{@type}')" title="{@type}" id="contact-{@type}-sitelink">
            <img alt="{@type}" src="{@type}.ico" id="contact-{@type}-icon" class="contact-icon" />
        </a>
        <xsl:if test="c:name">
            <a href="javascript:alert('{@type}:{c:id}');" id="contact-{@type}-link" title="{c:id}" alt="{c:name}" class="contact-link">
                <xsl:value-of select="c:name"/>
            </a>
        </xsl:if>
        <xsl:if test="not(c:name)">
            <a href="javascript:alert('{@type}:{c:id}');" id="contact-{@type}-link" title="{c:id}" alt="{c:id}" class="contact-link">
                <xsl:value-of select="c:id"/>
            </a>
        </xsl:if>
        <span class="contact-type">(<xsl:value-of select="@type"/>)</span>
    </li>
</xsl:template>

<xsl:template match="/c:contacts">
    <ul id="contacts">
    <xsl:for-each select="./c:contact">
        <xsl:call-template name="contact" />
    </xsl:for-each>
    <xsl:for-each select="./c:group">
        <li>
            <xsl:if test="c:name">
                <span class="contact-group-name"><xsl:value-of select="c:name"/></span>
            </xsl:if>
            <ul id="{@shortname}">
                <xsl:for-each select="./c:contact">
                    <xsl:call-template name="contact" />
                </xsl:for-each>
            </ul>
        </li>
    </xsl:for-each>
    </ul>
</xsl:template>

</xsl:stylesheet>

```

В результате преобразования получается такой блок XHTML:

![XHTML Rendering Result]({{ get_figure(slug, 'xml-rendering-result.jpg') }})

### JavaScript

Настало время выполнить само преобразование на стороне клиента. В этом абзаце придётся использовать немного больше хитростей, ввиду того, что каждый браузер предлагает это делать по-своему.

### Загрузка XML-файлов

Для начала нам потребуется загрузить оба файла — XML и XSLT. По своей природе они оба — файлы XML,  Internet Explorer предоставляет для этих целей ActiveX-объект `XMLDOM`, Firefox и Opera — фунцию `createDocument`, позволяющую загрузить XML-файл в созданный объект. Safari и Chrome (_Читай:_ WebKit), однако, предоставляя эту же функцию, возвращают объект, не поддерживающий загрузку — опять же, вполне разумно, в соответствии со спецификациями W3C.

#### Метод 1. XMLHttpRequest

Поэтому, плюнув на всё, мы можем загружать файлы через `XMLHttpRequest` (_синхронный_ или нет — по вашему выбору), используя всем известный шаблон AJAX.

Предложу вам свою версию, вы же можете использовать [какую только заблагорассудится](http://ajaxpatterns.org/XMLHttpRequest_Call).  Моя версия отличается тем, что принимает в параметры функцию, которая будет вызвана при успешном завершении вызова, позволяет делать и `POST` и `GET` запросы, позволяет передавать объекты и позволяет делать синхронный вызов (тогда она возвращает объект по его завершению).

``` javascript

/**
 * Browser-independent [A]JAX call
 *
 * @param {String} locationURL an URL to call, without parameters
 * @param {String} [parameters=null] a parameters list, in the form
 *        'param1=value1&param2=value2&param3=value3'
 * @param {Function(XHMLHTTPRequest, Object)} [onComplete=null] a function that
 *        will be called when the response (responseText or responseXML of
 *        XHMLHTTPRequest) will be received
 * @param {Boolean} [doSynchronous=false] make a synchronous request (onComplete
 *        will /not/ be called)
 * @param {Boolean} [doPost=false] make a POST request instead of GET
 * @param {Object} [dataPackage=null] any object to transfer to the onComplete
 *        listener
 * @return {XHMLHTTPRequest} request object, if no exceptions occured
 */
function makeRequest(locationURL, parameters, onComplete, doSynchronous, doPost, dataPackage) {

    var http_request = false;
    try {
        http_request = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e1) {
        try {
            http_request= new ActiveXObject("Microsoft.XMLHTTP");
        } catch (e2) {
            http_request = new XMLHttpRequest();
        }
    }

    //if (http_request.overrideMimeType) { // optional
    //  http_request.overrideMimeType('text/xml');
    //}

    if (!http_request) {
      alert('Cannot create XMLHTTP instance');
      return false;
    }

    if (onComplete && !doSynchronous) {
        completeListener = function() {
            if (http_request.readyState == 4) {
                if (http_request.status == 200) {
                    onComplete(http_request, dataPackage)
                }
            }
        };
        http_request.onreadystatechange = completeListener;
    }

    //var salt = hex_md5(new Date().toString());
    if (doPost) {
        http_request.open('POST', locationURL, !doSynchronous);
        http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http_request.setRequestHeader("Content-length", parameters.length);
        http_request.setRequestHeader("Connection", "close");
        http_request.send(parameters);
    } else {
        http_request.open('GET', locationURL + (parameters ? ("?" + parameters) : ""), !doSynchronous);
        //http_request.open('GET', './proxy.php?' + parameters +
                    // "&salt=" + salt, true);
        http_request.send(null);
    }

    return http_request;

}

```

При использовании этого метода, функция загрузки XML будет выглядеть довольно просто — например, так:

``` javascript

/**
 * Loads any XML using synchronous XMLHttpRequest call.
 * @param {String} fileName name of the file to be loaded
 * @return {XMLDocument|Object}
 */
function loadXML(fileName) {
                                              // no parameters, no handler, but synchronous
    var request = makeRequest(fileName, null, null, true);
    return request.responseXML;
}

```

#### Метод 2. В зависимости от браузера

Однако, если вы хотите использовать именно те способы, которые (как ни забавно) [рекомендуются](http://www.w3schools.com/xsl/xsl_client.asp) на W3Schools, функцию `loadXML` придётся усложнить, потому что приведённые на W3Schoolds примеры не работают на браузерах WebKit (_Читай:_ Safari и Chrome). Пусть это будет, так сказать, _«рекомендованный вид»_. Подозреваю, правда, что все эти обходы скрывают под собой те же вызовы XMLHttpRequest, поэтому, если вы не сторонник неоправданных действий, пропустите этот раздел.

Итак, функция будет делать прямой синхронный вызов XHMHttpRequest (вернее, функции описанной в предыдущем разделе) только в случае вызова из Safari, в остальных же случаях прибегать к средствам конкретного браузера (Не забываем правило: _Никаких прямых проверок браузера, только проверка, поддерживается ли вызываемая функция_):

``` javascript

/**
 * Loads any XML document using ActiveX (for IE) or createDocumentFunction (for
 * other browsers)
 * @param {String} fileName name of the file to be loaded
 * @return {XMLDocument|Object}
 */
function loadXML(fileName) { // http://www.w3schools.com/xsl/xsl_client.asp
    var xmlFile = null;

    if (window.ActiveXObject) { // IE
        xmlFile = new ActiveXObject("Microsoft.XMLDOM");
    } else if (document.implementation
            && document.implementation.createDocument) { // Mozilla, Firefox, Opera, etc.
        xmlFile = document.implementation.createDocument("","",null);
        if (!xmlFile.load) { // Safari lacks on this method,
    	   // so we make a synchronous XMLHttpRequest
            var request = makeRequest(fileName, null, null, true);
            return request.responseXML;
        }
    } else {
        alert('Your browser cannot create XML DOM Documents');
    }
    xmlFile.async = false;
    try {
        xmlFile.load(fileName);
    } catch(e) {
        alert('an error occured while loading XML file ' + fileName);
    }
    return(xmlFile);
}

```

В результате, функция возвращает XML-объект по заданному имени файла. Можно приступать собственно к трансформации.

### Преобразование через XSLT

Преобразованием будет заниматься ещё одна функция, которая будет принимать в качестве аргументов пути к XML-файлу и XSL-файлу. Загружать эти файлы она будет описанной выше функцией  `loadXML`. А возвращать эта функция будет строку с XHTML-кодом, который можно будет вставить прямо в `innerHTML` нужного элемента.

Почему строку? Потому что метод `transformFragment` объекта `XSLTProcessor` не поддерживает рендеринг XML (`xsl:output method="xml"`), а поддерживает только HTML (`xsl:output method="html"`). В результате преобразования с `xsl:output method="xml"` и `transformFragment` генерируется корректный `DocumentFragment`, который, однако, при вставке в XHTML-код действует как некая XML-нода — поэтому визуально виден только, так называемый, `plain text`. Если вас не смущает потеря пространств имён, вы можете изменить `xsl:output method` на `html` и использовать `transformFragment`, добившись в результате, чтобы функция возвращала `DocumentFragment`.

В случае Internet Explorer используется функция `transformNode` XML-объекта, в остальных браузерах используется `XSLTProcessor`.

``` javascript

/**
 * Applies specified XSL stylesheet to the specified XML file and returns
 * the result as a string. ActiveX is used in IE, otherwise, XSLTProcessor
 * is used.
 * @param {String} xmlFileName path to the xml file to be transformed
 * @param {String} xslFileName path to the xsl file to be applied to the xml
 * @return {String} xsl transformation result as a text
 */
function getStylingResult(xmlFileName, xslFileName) {
    var xmlContent = loadXML(xmlFileName);
    var xslContent = loadXML(xslFileName);
    if (window.ActiveXObject) { // IE
        return xmlContent.transformNode(xslContent);
    } else if (window.XSLTProcessor) { // Mozilla, Firefox, Opera, Safari etc.
        var xsltProcessor=new XSLTProcessor();
        xsltProcessor.importStylesheet(xslContent);
        // return xsltProcessor.transformToFragment(xmlContent, document);
            // somehow, transformToFragment works incorrectly, recognizing the
            // result of transformation as xml, not html, because
            // xsl:output="xhtml" is still not supported, and for xhtml
            // xsl:output="xml" is used
            // (xsl:output="html" strips namespaces)
            // see: http://osdir.com/ml/mozilla.devel.layout.xslt/2003-10/msg00008.html
            // also, see: https://developer.mozilla.org/en/Using_the_Mozilla_JavaScript_interface_to_XSL_Transformations
        var resultDocument = xsltProcessor.transformToDocument(xmlContent);
        var xmls = new XMLSerializer();
        return xmls.serializeToString(resultDocument);
    }
}

```

### Итог

Всё, весь необходимый код готов и вы можете использовать функцию `getStylingResult` для преобразования XML-файлов и вставки результата в XHTML. Например, таким образом:

``` javascript

document.getElementById('content').innerHTML =
            getStylingResult('./contacts.xml', './contacts.xsl');

```

Как итог, мы получили действительно кросс-браузерную версию обработки XML на клиенте. Спасибо за внимание.

------

**P.S.** Для того, чтобы иметь возможность передавать параметры XSL-шаблону через метод `addParameter`, в качестве документа XSL нужно использовать экземпляр `Msxml2.FreeThreadedDOMDocument.3.0`, а не обычный `Microsoft.XMLDOM`. Если вам это необходимо, обратитесь к [данной статье](http://www.mindlence.com/WP/?page_id=224) (вам потребуется перегрузить функцию `loadXML` из моего примера).

**P.P.S.** И да, с использованием JQuery всё [делается](http://johannburkard.de/software/xsltjs/) [проще](http://jquery.glyphix.com/), но ведь иногда приходится обходиться без JQuery...
