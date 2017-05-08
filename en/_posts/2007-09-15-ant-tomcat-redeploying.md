---
layout: post.html
title: Redeploying an Application to Tomcat with Ant
datetime: 15 Sep 2007 12:38
tags: [ tomcat, ant, java ]
---

The process of out project development has one drawback, which is common to many serious J2EE-projects: after applying changes to the code code and further recompilation, a server do not catches a new version automatically, but requires stoping it, cleaning cache, restarting it again and then, redeploying a package.

Not to make this by hands every time, there are several ways to automate it manually (hm...): for example, a batch or shell scripts for Windows or Linux accrodingly. But it seems to me, that it is more logical to entrust this work to the compiling ant-script: you press a button and everything restarts and reassembles by itself.

(this version is for Windows)

So I have taken an existing script and started to revise it. I've found several tricks about ant on Windows (but they are, may be, a common thing for a man who experienced with ant building :) ), and I've got the following script as a result.

Here is the `build.properties` file. It contains a values that may change frequently so it is better to store them separately from the ant script.

``` ini

# package name
war.name = SomeProjectPackage

# path to JDK
java.home = "C:\Worktable\Java\jdk1.5.0_12"
# path to the server root directory
server.dir = C:/Worktable/Java/apache-tomcat-5.5.25
# script that is used to start server
server.command = catalina.bat

# path to the project root directory
root.dir = C:/Workspace/SomeProject
# path to the place where package must be deployed
deploy.dir = ${server.dir}/webapps/

# JPDA setting (you can use a remote debugging by
# (for example, Eclipse can) connecting to the specified port)
jpda.transport = dt_socket
jpda.port = 56666

# path to the project libraries
lib.dir = ${root.dir}/lib/
# path to the project's temporary assemblage place
dist.dir = ${root.dir}/dist/
# path to the directory with web-content: pages, scripts, images and so on
web.dir = ${root.dir}/WebContent/

```

Now let us consider the script part by part. In the heading - we include our `.properties` file.

``` xml

<?xml version="1.0" encoding="UTF-8"?>

    <project name="SomeProject" default="redeploy" basedir=".">
    <property file="build.properties"/>

    . . .

```

Now the compilation target goes (`build`), the target cleaning temporary directories used while building (`clean`), and the rebuilding which, in fact, cleans and then builds the package (`rebuild`).

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

And now the subject targets of the article -- a deploying target (put a new package to the servers), de-deploying target (taking an old package from server) and re-deploying target (which, in fact, takes and then puts).

When deploying (`deploy`) we compile the code (`depends="build"`), then create the logs directory at the server, then constructing a package from the compiled sources (with `jar` command) and putting it to a temporary directory, and then we start a server. The server can be started from ant-script only from inside its own environment, in case of Windows, so we need to call it using `cmd /c catalina.bat jpda start` command with ant `exec` (arguments must be separated the exactly same way as you see them below -- `exec` must wrap the whole `catalina jpda start` command with quotes correctly). Also we need to pass several environment variables to server, what we do using `env` commands. The server is started in separate thread (`spawn="true"` -- or else the script will inactively wait for a server to return an exit code that will not happen while server is running) and in the clean way (not using java-vm -- `vmlauncher="false"`). Now server is running, we can deploy a package there and then clean up the temporary directories and files (`copy` and `delete` commands sequence).

To unload a package from server (`undeploy`) we stop the server using the rules specified above (when stopping we can't specify JPDA variables and wait for a server to stop; but if something had failed -- it is a normal state -- may be a server was not started at all (`failifexecutionfails="false"`)). Then we clean up the directory at the server where our package was deployed (being unpackaged), removing the package itself and we clean the server cache.

When we redeploy (`redeploy`) -- a default target -- the old version of the package is removed from the server (`undeploy`), temporay directories are cleaned up (`clean`), then package is constructed and deployed to server (`deploy`).

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

Seems that's all :)

**P.S.** Yes, as people give me advices, there is [Tomcat Client Deployer](http://tomcat.apache.org/tomcat-5.5-doc/deployer-howto.html#Deploying%20using%20the%20Client%20Deployer%20Package) -- a package that has a levers to re-deploy with Ant, but it requires a server to be running all the time.

And yes, there are another ways to do it like [CruiseControl](http://cruisecontrol.sourceforge.net/) but it seems for me, it is not so required to setup a packages like this just to redeploy something fast.

And yes I also know now that [Maven](http://maven.apache.org/) has a [war-plugin](http://maven.apache.org/maven-1.x/plugins/war/goals.html) for something similar our targets... Maven is fat, forget it :)
