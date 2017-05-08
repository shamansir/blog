---
layout: post.html
title: JSP Custom Tags
datetime: 15 May 2006 19:06
tags: [ java, jsp ]
---

Let the first post will be about custom-tags for [JSP](http://java.sun.com/products/jsp/), for example (and Java Server Faces, I think, will also follows these rules). There is a lot of information about them, but I've wanted to introduce you my sight and also to start from something relatively easy, though.

As an example, I'll show you a little bit tricky tag, but kindly demonstrating the possibilities of tags-fabrication.

The task is to integrate in JSP code an option to change style of the text wrapped with this tag, depending on passed value. A demonstrative example is rendering a table of tasks having different priorities, low ones - with italic text, high ones - with bold and doing no changes to style of the tasks with normal priority. Also, it was required to have possibility to pass CSS-style to text, that's why the specification of the tag is event larger than its realization in result :).

Ok, let's take a decision what properties this tag must own. Obviously, it must have body, containing the text to change style. It must have a required attribute with the value of current task priority level and a several optional attributes (initialized with default values) - numeric value of middle level of priority, style (bold by default, for example) for the values with high priority and style for the values with low priority.

This is the specification:

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

So, using some funny symbols and aliases, I've included a support of almost everything that user might want :)

> I will include some XDoclet-tags in the code, so you'll have a possinility to generate a record in `.tld`-file if you'll need to.

Following the specification, let us define our tag in `.tld`-file (a library of tags):

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

So the body of our tag is something calculated with JSP-code (normal text results in normal text), `value` attribute is required and contains an equation, all other attributes are optional.

Now, not to be a downers - let's define our tag class:

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

By extending a tag from `BodyTagSupport`, we mean that this tag will have a body. The values are discarded in `release()` method, attributes values are set in compiled JSP - HTTP-servlet - with help of accessors. Methods `doStartTag()` `doAfterBody()` and `doEndTag()` are overriden from the parent (and they implement `Tag` interface by the way) and they are called in the specified order - after evaluation of opening tag, after evaluation of tag body, and after evaluation of closing tag respectively.

`doStartTag()` returns `EVAL_BODY_BUFFERED` constant to evaluate tag body right after this method. `doAfterBody()` sets `body` to the `value` value if there is no text inside the tag and returns `SKIP_BODY` not to let tag body be returned to output without processing required. `doEndTag()` does the main thing - using the value and attributes settings it generates an output code, calls `release()` (or the values of attributes will be saved for next tags) and returns `EVAL_PAGE` to say `jasper` (JSP compiler) to follow the chain of tags forward through the page content.

If our tag was designed not to have a body (`empty` in `.tld`) - we'd extend it from `javax.servlet.tagext.TagSupport` (which is parent of `BodyTagSupport` following the same reasons) and nothing but `release()` and `doEndTag()` (return `EVAL_PAGE`) methods would be required.

Now let's look on the usage of tag:

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
