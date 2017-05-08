---
layout: post.html
title: Google Wave Client as Java Web Application
datetime: 13 Oct 2009 07:09
tags: [ google-wave, java, javascript, ajax, dwr ]
---

Zdrawstwooyte.

[![sametimed]({{ get_figure(slug, 'logo.png') }})](http://code.google.com/p/sametimed)

...So I wrote a small project in Java, which is a client for Google Wave, which in its turn can be extended with the features you need. Its current visual style is not very presentable <s>(though, why not, a-la Windows 3.1 ;) )</s>, 'cause I am not so good in web-design - but for all the project's source code I am responsible with my head :). Then, for example, the required CSS-styles looks the most understandable and the XHTML-structure is the most simplified (not to the detriment of standards) and the real designer can apply his skills in most and make this all look really beautiful.

[![screenshot]({{ get_figure(slug, 'screenshot.png') }})]({{ get_figure(slug, 'screenshot-full.png') }})

Source code and war-package with current condition of the project are located at [http://code.google.com/p/sametimed](http://code.google.com/p/sametimed)

Right now I have no public hosting ready at hand, so I can't show the project in action with ease. However I can, may be, please you with a [video (at vimeo)](https://vimeo.com/7036141), it demonstrates its main possibilities, and perhaps it is pretty enough if you just want to know what the project can do. Anyway, you can run it by yourself, since there are detailed instructions at project site and the detailed source code inspection and concept description are in this very post...

[![video]({{ get_figure(slug, 'vimeo.png') }})](http://vimeo.com/7036141)

### Installation

Just four items required to run this client:

 * Client WAR-package, you can take it at [googlecode project](http://code.google.com/p/sametimed)
 * Wave-protocol server installed with default settings, current version (0.2) ([installation tutorial](http://code.google.com/p/wave-protocol/wiki/Installation))
 * Any web-сервер applying Java EE specification (I used Jetty server integrated in Eclipse)
 * Firefox browser

The more detailed instruction on [how to run the client per se](http://code.google.com/p/sametimed/wiki/SametimedInstallationInstructions) or [as working Eclipse project](http://code.google.com/p/sametimed/wiki/CreatingEclipseProject) are at the project page. Here I will consider the code structure and will describe how it works (sorry, without UML-diagrams).

### General concept

> Here when I mention «server side» I mean not a wave-protocol server, but a server side of web-application.

Because there is only console (terminal) client for wave-protocol released now as a simple desktop jar-application, the main question is how to transfer information from web-client to server and back well-timed.

That's why it's necessary to introduce the two notions:

 * **Command**: is sent from client to server and asks to "open a wave", "add a participant", "undo some action", "say hi" & s.o., it is sent after user makes some action to call it.
 * **Message**: is sent from server to client and reports/informs that "someone has invited to a wave", «sonya replied hi», «participant was added to wave», «error happened» & s.o., it is sent with every update related to current client.

With this rules, a command may be sent from client immediately, not much thinking about server load, but the messages about updates are required to be sent only on the fact of the event. However, we have Javascript at server-side and currently it can not handle a things like these. It is the moment when [Reverse Ajax](http://en.wikipedia.org/wiki/Reverse_Ajax) was needed, rather its Java realization - [DWR](http://directwebremoting.org/dwr/index.html) (Direct Web Remoting) library. It allows to call some client function from the server in the time when server decides but not client. Their site describes all the features which are not limited with this application.

**Upd**: Current source code state is rewriting to `cometd` library, this library is more simple and hm... intuitive. And we're waiting for WebSockets...

Commands and messages are sent in XML, and the content of messages about updates is sent in JSON, that's why JavaSvript is the only one who builds a user interface (I've used JQuery), and a server side is don't even thinks about existence of UI.

> (there is a `Renderer` interface for server-side in project, its realization is called on required updates, but it is just intended for the cases similar to console client)

### Current flow description

When you run a client, you see a page with text input for username and a single button. Wave-protocol server is required to be running herwith. When you press a button, the username you've got is passed to servlet (`GetClientViewServlet`), which connects you to a wave and returns the complete client model in JSON view. On the client side, JQuery build full wavelet insterface using this info. If you'll press this button again, you'll request another wavelet, they both [wavelets] will differ in internal ID (which is generated automatically) that is shown on a blue bar in brackets. Using this ID both server and client determine which client is owner/target for command or a message.

At the same time DWR starts to wait for updates, so you can enter one of allowed commands and press "send". For example, you can create a wave with "`\new`" command, open it with "`\open <id>`" command and say something just by entering the text (like in Skype). When you press "send" button, POST request is sent to another servlet (`CommandsReceiverServlet`), who gets the generated XML-command and permorms it immediately, passing the data to wave-protocol server.

Currently the updates are coming from server-side (and from wave-protocol server) in XML-encoded message (there is a callback on a client-side which called when new messages arrive), that includes the alias of the changed model (i.e. "chat", "inbox", "userslist", "errors" or "editor") and its content in JSON view, which is decoded immediately and updates the corresponding wavelet part.

**Upd:** I really do not remember why I haven't used JSON in JSON packages (without XML).

As you see, everything is simple.

### Project structure

#### Java:

 * **`name.shamansir.sametimed.wave`** _All the classes that lie "outside" and that are directly related to client_; here are the abstract `AUpdatingWavelet` and `ADocumentsWavelet` classes, they determine the structure of the according wavelet type (the updating wavelet and its extension, a wavelet containg documents). `SimpleWavelet` class is an example of such realization. `WavesClient` class handles all the commands and returns the model of wavelet it contains to `GetClientViewServlet`.
 * **`name.shamansir.sametimed.wave.messaging`** _All the things related to commands and messages_; Commands/messages identifiers in `CommandID`/`MessageTypeID`, the `Command` and `UpdateMessage` classes themselves, and the commands receiving servlet `CommandsReceiverServlet`.
 * **`name.shamansir.sametimed.wave.model`** _Classes that define wavelet model_; They contain each sub-model definition, like a participants list, chat ot text document. And a `ModelID` classes that define the possible models with abstract `AModel` class. Plus `ModelFactory`, model factory.
 * **`name.shamansir.sametimed.wave.model.base`** _The models values, something like "chat lines set", "document text blocks set", "list of waves online" and so on_; Here in these classes the encoding to JSON is defined.
 * **`name.shamansir.sametimed.wave.model.base.atom`** _What values are consist of, if it is required for their structure — «chat line», «text block», «wave identifier»_;
 * **`name.shamansir.sametimed.wave.model.base.chat`** _Wavelet with chat extension and its client_;
 * **`name.shamansir.sametimed.wave.model.base.editor`** _Wavelet with editable document support extenstion, not implemented currently, so disabled_;
 * **`name.shamansir.sametimed.wave.render`** _Classes related to rendering_; There is the very class `JSUpdatesListener` that calls updates callback function at client using DWR.

The most logical way to make an extension is to implement `ADocumentWavelet` class and to extend `WaveletWithChat` class. Since in the most likely case you will operate with a "document" term (and a chat or anything other in this style is a document), this approach will fit you best. Also you'll need to realize what you document model is (by implementing `AModel` with some type, adding model ID in `ModelID` enum and adding this model generation in `ModelFactory`).

If your document will not handle any new commands, then it is enough - you can replace the wavelet that `GetClientViewSelvlet` returns with your own and voila!.. Oh yes, do no forget to build UI at the client, but I'll mention it below.

Else, if you'll need your own commands, strictly related to your document, you need to add these commands to `CommandID` type. After that, you need to extend `WavesClient` class to support your wavelet and to make it handle and pass new commands to wavelet independently from parent class. And, in this case, replace the `WavesClient` implementation in `GetClientViewServlet` with your and voila again! (and again, not mentioning the UI)

You'll need, of course, to handle some tricks when writing commands processing, but in outline it is all the required process for client extension.

#### JavaScript

 * **`ui.js`** is involved in the UI generation, each model block has the corresponding method
 * **`command.js`** sends and generates commands, gets updates messages and contains buttons handlers
 * **`ajax.js`** script to be replaced with the appropriate JQuery method, but my hands haven't reached it :). used in `command.js`

To add UI generation for your model, you need just to add a line that calls your handling method in `createClient` and `renderUpdate` methods of `ClientRenderer` object in `ui.js` and to write that method itself. Everything else will (must to) work on its own.

#### CSS

 * **`sametimed-plain.css`** interface that is even a little bit worse than colored :)
 * **`sametimed-colored.css`** Windows-3.11-like, colored interface

Currently the styles that handle positioning and the appearance (coloring) are not separated in different files (just using comments in that files), but may be I plan to.

### Epilogue

I hope there will be a person who will be interested in this project, and if there will be, I plan to improve it more. For this moment, it is just an odd job "for interest", but a little more efforts - ant it can become a sterling project.

I ask those who will test it to send issues and bugs to the [appropriate place](http://code.google.com/p/sametimed/issues/list), within reasonable limits and not about design :).

Participation in development is welcomed, but only for free license :).

#### An important notice

If you will test this application simultaneously with wave-protocol console (terminal) client, the messages that you send from terminal client will be received one later. It is not a bug and not an issue, it a way how chat "document" is generated. In the case of terminal Google had changed the document elements order so that is will be readable in console (as I suppose) - element start, element end and its body next). In my case the document is built in a "standard" way (start, body, end), this is the reason of discrepancy. If you will correct the way of generation either in my code or in terminal client code to be the same, they will fully comply with each other.

And yes, no input validation is performed currently at client.

