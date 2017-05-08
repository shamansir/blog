---
layout: post.html
title: JSP Custom tags
datetime: 15 May 2006 19:06
tags: [ java, jsp ]
---

Расскажу вам для затравки, например, о кастом-тэгах для [JSP](http://java.sun.com/products/jsp/) (а по принципу - и для каких-нибудь там Java Server Faces). Информации об этом действительно не так уж мало. Но тем не менее хотелось предложить для начала что-нибудь простенькое дабы развернуть тему.

В качестве примера я решил взять свой немного хитрый, но зато относительно широко показывающий возможности тего-фабрицирования, тег.

В качестве задачи нам требуется встроить в JSP возможность изменения стиля текста, обрамленного тегом, в зависимости от величины переданного значения. Яркий пример - отображение в таблице задач с небольшими приоритетами - курсивом, а задач с высокими приоритетами - жирным шрифтом, стиль задач с нормальным приоритетом при этом не меняется. Кроме того, требовалась возможность передать тегу запись CSS-стиля, поэтому спецификация тега получилась даже больше его реализации :).

Что ж, посмотрим какие свойства должен иметь тег. У него, разумеется, должно быть тело, содержащее текст, подлежащий изменению стиля. У него должен быть обязательный атрибут со значением текущего уровня задачи и несколько необязательных (забитых дефолтовыми значениями) атрибутов - численное значение среднего уровня приоритета, стиль (по умолчанию, допустим, жирный) для значения с высоким приоритетом и стиль для значения с низким приоритетом.

Спецификация получилась примерно такой:

``` java

/**
 * @author uwilfred
 *
 * Adds priorityFontTag, specified in .tld as
 *      <prefix:priorityFont
 *      value = Integer       // priority value; if tag body not
                specified, also specifies the value
 *      [ level = Integer ]       // priority level to change the
                style on
 *      [ lowChange = String ]    // style description to apply
                if priority less than level (format listed below)
 *      [ highChange = String ]   // style description to apply
                if priority greater than level (format listed below)
 *      ( /> |
 *          body                  // value
 *      </prefix:priorityFont> )  // may be empty tag,
                    so the value it taken from priority value parameter
 *
 *  default for highChange is “bold”
 *  default for lowChange is “italic”
 *  default for level is 3
 *
 *  Formats:
 *      bold                                  -> <strong>body</strong>
 *      italic                                -> <em>body</em>
 *      underline                             -> <u>body</u>
 *      strike                                -> <strike>body</strike>
 *      .<css-class>            .foo          -> <span class=”foo”>body</span>
 *      {<css-style>; ...}  	{font-weight: bold;} -> <span style="font-weight: bold;">body</span>
 *      /<html-tag-name>    /foo              -> <foo>body</foo>
 */

 ```

То есть за счёт всяких хитрых символов и алиасов я включил поддержку практически любых желаний пользователя :).

В код класса тега я также включу XDoclet-теги по которым при необходимости можно будет сгенерировать запись в `.tld`-шке.

По спецификации, опишем тег в `.tld`-файле - библиотеке тегов:

``` xml

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE taglib PUBLIC
    "-//Sun Microsystems, Inc.//DTD JSP Tag Library 1.1//EN"
    "http://java.sun.com/j2ee/dtds/web-jsptaglibrary_1_1.dtd">
<taglib>
   <tlibversion>1.0</tlibversion>
   <jspversion>1.1</jspversion>
   <shortname>uwilfred</shortname>

   <tag>

      <name>priorityFont</name>
      <tagclass>org.individpro.uwilfred.tag.PriorityFontTag</tagclass>
      <bodycontent>JSP</bodycontent>

      <attribute>
         <name>value</name>
         <required>true</required>
         <rtexprvalue>true</rtexprvalue>
      </attribute>

      <attribute>
         <name>highChange</name>
         <required>false</required>
      </attribute>

      <attribute>
         <name>level</name>
         <required>false</required>
      </attribute>

      <attribute>
         <name>lowChange</name>
         <required>false</required>
      </attribute>

   </tag>

</taglib>

```

Значит тело нашего тега - это нечто, вычисляемое засчет JSP-кода (обычный текст на выходе дает текст), атрибут `value` необходим и содержит выражение, все остальные атрибуты необязательны.

Ну и сразу чтобы не тянуть - описываем класс тега:

``` java

package org.individpro.uwilfred.tag;

import java.io.IOException;
import javax.servlet.jsp.JspException;

import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.tagext.BodyContent;
import javax.servlet.jsp.tagext.BodyTagSupport;
import javax.servlet.jsp.tagext.Tag;

/**
 * @note adds specified-level style change support
 * @author uwilfred
 *
 * @jsp.tag
 *   name="priorityFont"
 *   body-content="JSP"
 */

public class PriorityFontTag extends BodyTagSupport implements Tag {

   private static final long serialVersionUID = -4941606719316390930L;

   private Integer value = -1;
   private Integer level = 3;
   private String lowChange = "bold";
   private String highChange = "italic";
   private String valueHtmlPrefix = "";
   private String valueHtmlPostfix = "";
   private String bodyTextContent = "";

   // TODO: private final Map that will store the styles replacements,
   //       like "bold" -> "strong", "italic" -> "em" & s.o.

   public void release() {
      value = -1;
      level = 3;
      lowChange = "bold";
      highChange = "italic";
      valueHtmlPrefix = "";
      valueHtmlPostfix = "";
      bodyTextContent = "";
   }

   /**
    * any variable to take the priority from, also
    * recognized as value if no body specified, default -1
    */

   public Integer getValue() {
      return value;
   }

   /**
    * @jsp.attribute
    *   required="true"
    *   rtexprvalue="true"
    */

   public void setValue(Integer value) {
      this.value = value;
   }

   /**
    * style description to apply to the content with value higher
    *		 than the level.
    *		 supports: bold, italic, underline or any
                                        body-having html tag or css-style
    *		     format: bold | italic | underline | strike
    *		         .<CSS-class>
    *		         {<CSS-Descriptors-Line>}
    *		         :<HTML-Tag-Name>
    *		 default: italic
    */

   public String getHighChange() {
      return highChange;
   }

   /**
    * @jsp.attribute
    *   required="false"
    */

   public void setHighChange(String highChange) {
      this.highChange = highChange;
   }

   /**
    * level point to change the style, default is 3
    */

   public Integer getLevel() {
      return level;
   }

   /**
    * @jsp.attribute
    *   required="false"
    */

   public void setLevel(Integer level) {
      this.level = level;
   }

   /**
    * style description to apply to the content with value lower
    *		 than the level.
    *		 supports: bold, italic, underline or any
                                    body-having html tag or css-style
    *		     format: bold | italic | underline | strike
    *		         .<CSS-class>
    *		         {<CSS-Descriptors-Line>}
    *		         :<HTML-Tag-Name>
    *		 default: italic
    */

   public String getLowChange() {
      return lowChange;
   }

   /**
    * @jsp.attribute
    *   required="false"
    */

   public void setLowChange(String lowChange) {
      this.lowChange = lowChange;
   }

   public int doStartTag() throws JspException {
      return EVAL_BODY_BUFFERED;
   }

   public int doAfterBody() throws JspException {
      try {
         BodyContent bodyContent = getBodyContent();
         if (bodyContent == null) {
            bodyTextContent = value.toString();
         } else {
            bodyTextContent = bodyContent.getString();
            if (bodyTextContent == null) {
               bodyTextContent = value.toString();
            }
         }
      } catch (NumberFormatException nfe) {
         nfe.printStackTrace();
         throw new JspException("jbpm:priorityFont
                        tag body couldn't be parsed", nfe);
      }
      return SKIP_BODY;
   }

   public int doEndTag() throws JspException {
      if (value == Integer.valueOf(-1)) {
         throw new JspException("jbpm:priorityFont tag requires
                  the body xor the value parameter to
                  be specified (also, negative values are unsupported)");
      }
      try {
         JspWriter jspOut = pageContext.getOut();
         String modificator =
                  (value < level) ? lowChange :
                           ((value > level) ? highChange : "");
         if (modificator.equalsIgnoreCase("bold")) {
            valueHtmlPrefix = "<strong>";
            valueHtmlPostfix = "</strong>";
         } else if (modificator.equalsIgnoreCase("italic")) {
            valueHtmlPrefix = "<em>";
            valueHtmlPostfix = "</em>";
         } else if (modificator.equalsIgnoreCase("underline")) {
            valueHtmlPrefix = "<u>";
            valueHtmlPostfix = "</u>";
         } else if (modificator.equalsIgnoreCase("strike")) {
            valueHtmlPrefix = "<strike>";
            valueHtmlPostfix = "</strike>";
         } else if ((modificator.length() > 1) &&
                                       (modificator.charAt(0) == '.')) {
            // CSS existing style specify
            valueHtmlPrefix = "<span class=\"" + modificator.substring(1) + "\">";
            valueHtmlPostfix = "</span>";
         } else if ((modificator.length() > 1) &&
                                       (modificator.charAt(0) == '/')) {
            // HTML tag redefine
            valueHtmlPrefix = "<" + modificator.substring(1) + ">";
            valueHtmlPostfix = "</" + modificator.substring(1) + ">";
         } else if ((modificator.length() > 2) &&
                (modificator.charAt(0) == '{') &&
                (modificator.charAt(modificator.length() - 1) == '}')) {
            // CSS style line
            valueHtmlPrefix = "<span style=\"" +
                   modificator.substring(1, modificator.length() - 1)
                   + "\">";
            valueHtmlPostfix = "</span>";
         } else if (modificator.length() > 0) {
             throw new JspException ("jbpm:priorityFont tag parameters
                    values couldn't be parsed");
         }
         jspOut.print(valueHtmlPrefix + bodyTextContent +
               valueHtmlPostfix);
      } catch (NumberFormatException nfe) {
         nfe.printStackTrace();
         throw new JspException("jbpm:priorityFont tag parameters
                        couldn't be parsed", nfe);
      } catch (IOException ioe) {
         ioe.printStackTrace();
         throw new JspException("jbpm:priorityFont tag parameters
                        couldn't be parsed", ioe);
      }
      release();
      return EVAL_PAGE;
   }

}

```

Наследуя тег от класса `BodyTagSupport` мы подразумевали, что у тега будет тело. Очистка значений происходит в методе `release()`, значения атрибутов устанавливаются в скомпилированной JSP - HTTP-сервлете - засчет аксессоров. Методы `doStartTag()`, `doAfterBody()` и `doEndTag()` перегружены от родителя (и имплементят соответствующие методы интерфейса `Tag`) и вызываются в указанном порядке - после обработки открывающего тега, после обработки тела и после обработки закрывающего тега соответственно.

`doStartTag()` возвращает константу `EVAL_BODY_BUFFERED` (вычислить тело в буфере), которая указывает, что тело тега надо вычислить. `doAfterBody()` забивает `body` значением из `value` если тело тега отсутствует - и возвращает `SKIP_BODY` (пропустить тело) дабы тело тега не попало в выходной HTML-код без соответствующей обработки. `doEndTag()` делает самое главное - на основе значения и установок атрибутов генерирует выходной HTML-код, делает `release()` (иначе значения атрибутов сохранятся для последующих тегов) и возвращает `EVAL_PAGE` (вычислить страницу) чтобы компилятор JSP (`jasper`) по цепочке пошел дальше по тексту страницы.

Если бы наш тег не должен был быть иметь тела (`empty` в `.tld`) - то мы бы наследовали его от `javax.servlet.tagext.TagSupport` (который по аналогичным причинам и является родителем `BodyTagSupport`) и по сути не должны были бы имплементить ничего кроме методов `release()` и `doEntTag()` (который возвращал бы `EVAL_PAGE`).

Ну и посмотрим на использование тега:

``` html

<%@ taglib uri="/WEB-INF/uwilfred.tld" prefix="uwilfred" %>...
<html><%
...
%>
<head>
   <style>

   .priorityHigh {
      font-color: #f00;
      font-weight: bold;
      border: 1px solid #333;
   }

   .priorityLow {
      font-color: #00f;
      font-style: italic;
      border: 1px dotted #999;
   }

   </style>

   <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
   <title>Test priorityFont Tag</title>
</head>

<body class="layout">

   <c:forEach items="${model.tasks}" var="task" varStatus="status">
      <uwilfred:priorityFont value="${task.priority}">
            <a href="taskinfo.htm?id=<c:out value="${task.id}"/>">
                  <c:out value="${task.name}"/>
            </a>
      </uwilfred:priorityFont>
   </c:forEach>

   <%-- is identical to: --%>

   <c:forEach items="${model.tasks}" var="task" varStatus="status">
      <uwilfred:priorityFont value="${task.priority}" level="3"
              highChange="bold" lowChange="italic">
         <a href="taskinfo.htm?id=<c:out value="${task.id}"/>">
            <c:out value="${task.name}"/>
         </a>
      </uwilfred:priorityFont>
   </c:forEach>

   <%-- different variants: --%>

   <uwilfred:priorityFont value="${someValue}"
            highChange="{font-color: #f00; font-weight: bold;}"
            lowChange="{font-color: #00f; font-style: italic;}">
                  BlahByCSSInline
   </uwilfred:priorityFont>

   <uwilfred:priorityFont value="${someValue}"
                                    highChange=".priorityHigh"
                                    lowChange=".priorityLow">
         BlahByCSSExistentClass
   </uwilfred:priorityFont>

   <uwilfred:priorityFont value="${someValue}"
               highChange=":strong"
               lowChange=":em">
         BlahByTagRedefine
   </uwilfred:priorityFont>

</body>

</html>

```
