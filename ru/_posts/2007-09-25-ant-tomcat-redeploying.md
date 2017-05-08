---
layout: post.html
title: Редеплойинг приложения на Tomcat средствами Ant
datetime: 15 Sep 2007 12:38
tags: [ tomcat, ant, java ]
---

Процесс разработки нашего проекта обладает одним минусом, свойственным многим J2EE-проектам: при изменении кода проекта и пересборке его сервер не сразу подхватывает обновку, а требует полного останова себя, очистки кэша, запуска себя по-новой и передеплойинга пакета.

Для того чтобы не делать это каждый раз ручками есть несколько простых способов: например, те же скрипты (batch’и для windows и shell-скрипты для linux). Но мне показалось более простым сделать так, чтобы делал это сам собирающий ant-скрипт (сценарий?): одно нажатие клавиши и все просходит автоматически…

(версия для windows)

Поэтому я взял скрипт существующий и стал его править. Пришлось столкнуться с несколькими проблемами/хитростями ant’а на windows (опытному в ant’о-строении человеку они конечно нипочем :) ), в результате чего получился рабочий скрипт, выдержки из которого я и разберу ниже.

Вот -- файл `build.properties`. Он содержит некоторые значения, которые возможно будут часто меняться и поэтому лучше хранить их отдельно от ant-срипта.

``` ini

# имя пакета
war.name = SomeProjectPackage

# путь к JDK
java.home = "C:\Worktable\Java\jdk1.5.0_12"
# путь к корневому каталогу сервера
server.dir = C:/Worktable/Java/apache-tomcat-5.5.25
# скрипт, использующийся для запуска сервера
server.command = catalina.bat

# путь к расположению проекта
root.dir = C:/Workspace/SomeProject
# путь к месту, куда на сервере будет выкладываться пакет
deploy.dir = ${server.dir}/webapps/

# настройки JPDA (удаленнный дебаггинг может осуществляться
# (например, средствами Eclipse) подключением к указанному порту)
jpda.transport = dt_socket
jpda.port = 56666

# путь к библиотекам проекта
lib.dir = ${root.dir}/lib/
# путь к временному месту сборки проекта
dist.dir = ${root.dir}/dist/
# путь к каталогу с веб-содержимым - страницами, скриптами и т.п.
web.dir = ${root.dir}/WebContent/

```

Теперь по частям рассмотрим сам скрипт. В заголовке - включаем наш файл `.properties`.

``` xml

<?xml version="1.0" encoding="UTF-8"?>

    <project name="SomeProject" default="redeploy" basedir=".">
    <property file="build.properties"/>

    . . .

```

Далее идут цели сборки (`build`), очистки временных каталогов, использованных при сборке (`clean`) и цель пересборки - очищающая, а затем собирающая (`rebuild`). Их подробное рассмотрение не относится к цели статьи :).

``` xml

    . . .

    <!-- Compiles project with all dependencies. -->

    <target name="build"
            description="--> compiles project with all dependencies">
        <mkdir dir="${dist.dir}"/>
        <mkdir dir="${dist.dir}/classes"/>
        <javac source="1.5"
            srcdir="${root.dir}/src"
            destdir="${dist.dir}/classes"
            debug="on"
            verbose="false"
            optimize="on">
            <classpath>
                <fileset dir="${lib.dir}" includes="**/*.jar"/>
            </classpath>
        </javac>
    </target>

    <!-- Cleans the build. -->

    <target name="clean"
            description="--> cleans the build">
        <delete quiet="true" dir="${dist.dir}"/>
    </target>

    <!-- Rebuild. -->

    <target name="rebuild" depends="clean,build"
            description="--> [clean, build]"/>

    . . .

```

А вот, собственно, наши подчиненные -- цели деплойинга (выкладывания нового пакета на сервер), де-деплойинга (забирания старого пакета с сервера) и пере-деплойинга (забирания старого, а потом выкладывания нового).

При выкладывании (`deploy`) мы компилируем код (`depends="build"`), затем создаем на сервере каталог для логов, собираем пакет из скомпилированных исходников (командой `jar`), выкладывая его во временный каталог, а затем запускаем сервер. Для Windows сервер из ant-скрипта может быть запущен только в своем окружении, для этого приходится вызывать его командой `cmd /c catalina.bat jpda start`, через команду ant’а `exec` (аргументы должны быть разделены командами `arg` именно так, как представлено ниже -- для того чтобы `exec` обернул команду `catalina jpda start` в кавычки, для ее целостности). Также серверу нужно передать несколько переменных окружения, что мы и делаем, используя команды `env`. Сервер мы запускаем в отдельном потоке (`spawn="true"` -- иначе скрипт будет ожидать от сервера команды завершения и не будет производить дальнейших действий) и в чистом виде (не через ява-машину - `vmlauncher="false"`). Сервер запущен, можно выложить туда пакет и удалить временные каталоги и файлы (последовательность команд `copy` и двух `delete`).

Для выгрузки пакета с сервера (`undeploy`) мы останавливаем серевер по правилам, описанным выше (при остановке мы можем не указывать переменные окружения для JPDA и подолждать пока сервер остановится; но если что-то не вышло -- это нормально -- возможно сервер и не был запущен (`failifexecutionfails="false"`)). Затем мы очищаем каталог на сервере, в которые он распаковывал наш пакет, удаляем сам пакет и очищаем кэш сервера.

При перевыладке (`redeploy`) - цели по умолчанию - старая версия пакета удаляется с сервера (`undeploy`), очищаются временные каталоги (`clean`), и пакет собирается и выкладывается на сервер (`deploy`).

``` xml

    . . .

    <!-- Prepares deployment -->

    <target name="pre-deploy">
        <mkdir dir="${dist.dir}/war"/>
        <mkdir dir="${dist.dir}/war/WEB-INF"/>
        <mkdir dir="${dist.dir}/war/WEB-INF/classes"/>
        <mkdir dir="${dist.dir}/war/WEB-INF/lib"/>
        <copy todir="${dist.dir}/war">
            <fileset dir="${web.dir}">
                <include name="**/*.*"/>
            </fileset>
        </copy>
        <copy todir="${dist.dir}/war/WEB-INF/classes">
            <fileset dir="${dist.dir}/classes">
                <include name="**/*.*"/>
            </fileset>
        </copy>
        <copy todir="${dist.dir}/war/WEB-INF/lib" flatten="true">
            <fileset dir="${lib.dir}">
                <include name="**/*.jar"/>
            </fileset>
        </copy>
    </target>

    <!-- Deploys application on server. -->

    <target name="deploy" depends="rebuild, pre-deploy"
            description="--> deploys application on server">
        <mkdir dir="${server.dir}/logs"/>
        <jar jarfile="${war.name}.war" basedir="${dist.dir}/war"/>
        <exec dir="${server.dir}/bin" executable="cmd"
                vmlauncher="false" spawn="true">
            <env key="JAVA_HOME" value="${java.home}"/>
            <env key="JPDA_TRANSPORT" value="${jpda.transport}" />
            <env key="JPDA_ADDRESS" value="${jpda.port}" />
            <env key="CATALINA_HOME" value="${server.dir}"/>
            <arg value="/c" />
            <arg value="${server.command} jpda start"/>
        </exec>

        <copy file="${war.name}.war" todir="${deploy.dir}"/>
        <delete dir="${dist.dir}" failonerror="false" />
        <delete file="${war.name}.war" failonerror="false" />
    </target>

    <!-- Un-deploys application from server. -->

    <target name="undeploy"
            description="--> un-deploys application from server">
        <exec dir="${server.dir}/bin" executable="cmd"
                failifexecutionfails="false" vmlauncher="false">
            <env key="JAVA_HOME" value="${java.home}"/>
            <env key="CATALINA_HOME" value="${server.dir}"/>
            <arg value="/c" />
            <arg value="${server.command} stop"/>
        </exec>

        <delete quiet="true">
            <fileset dir="${deploy.dir}">
                <include name="${war.name}*"/>
            </fileset>
        </delete>

        <delete dir="${deploy.dir}/${war.name}" failonerror="false"/>
        <delete file="${deploy.dir}/${war.name}.war" failonerror="false" />
        <delete dir="${server.dir}/work/Catalina" failonerror="false" />
    </target>

    <!-- Re-deploys application on server. -->

    <target name="redeploy"
            depends="undeploy,clean,deploy"
            description="--> [undeploy,clean,deploy]">
    </target>

    </project>

</xml>

```

Собственно, все :)

**P.S.** Действительно, как мне подсказывают, есть [Tomcat Client Deployer](http://tomcat.apache.org/tomcat-5.5-doc/deployer-howto.html#Deploying%20using%20the%20Client%20Deployer%20Package) -- пакет, имеющий свои средства (в том числе таски) для деплоинга через Ant, но требующий сервер быть всегда запущенным.

И конечно же, чтобы избежать новых претензий, есть дополнительные средства, облегчающие этот процесс вроде [CruiseControl](http://cruisecontrol.sourceforge.net/) и так далее - при большом количестве проектов и действительно большой команде они бы, возможно, были бы хорошим решением (пока у меня такого опыта [к счастью?] нет).

А ещё у [Maven](http://maven.apache.org/) есть, например, [war-плагин](http://maven.apache.org/maven-1.x/plugins/war/goals.html). Я об этом тоже знаю, правда-правда :).
