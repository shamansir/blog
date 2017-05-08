---
layout: post.html
title: Разбирая фонтан на Renderscript
datetime: 11 Feb 2011 10:26
tags: [ android, renderscript ]
---

**Примечание**: Это не авторская статья, но мой вольный перевод [статьи из далёкого 2009 года](http://www.inter-fuser.com/2009/11/android-renderscript-more-info-and.html), в которой написавший её [Neil Davies](http://www.inter-fuser.com/) знакомится с Renderscript и разбирает (не запуская) код из примера Fountain, выдранного из исходников Android. Что такое Renderscript и как он относится к Андроидам подробно рассказано [здесь](http://habrahabr.ru/blogs/android_development/113535/); вкратце - это возможность нативной (без каких-либо прослоек) работы с 3D-механизмами мобильных систем на Android. Вот, кстати, [исходники этого самого примера](http://www.andrada-dev.org/android-sdk-mac_x86/samples/android-Honeycomb/RenderScript/Fountain/src/com/android/fountain/) в Honeycomb. Я осознаю, что эта статья не содержит ничего большего чем  разбор исходников, но это пока единственная статья на тему которая, возможно, поможет кому-то легче вникнуть в эту самую тему, чтобы быть в теме... короче:

### Разбирая фонтан на Renderscript

Вот несколько суждений, которые я вывел для себя, столкнувшись с Renderscript:

 * Комилируется на самом устройстве
 * Использует компилятор `acc`
 * Нет проблем с поддержкой различных архитектур
 * Не используются внешние библиотеки
 * Никаких `#include`
 * Не разрешается выделять память
 * Довольно предсказуем

Я признаю, что некоторые из этих утверждений не особо информативны, но на данный момент особо и негде развернуться. Стоит заметить, что сам язык компилируем и похож на C но, похоже, не имеет всей силы C, поскольку выделения памяти запрещены.

В попытках пролить для себя больше света на суть проблемы, я ещё раз взглянул на исходные коды и нашёл пару простых примеров, использующих renderscript, представленных в виде Android-приложений. Один из этих примеров назывался Fountain и, похоже, был наиболее простым из этих приложений, так что я решил - начну именно с него.

#### Пример Fountain на Android Renderscript

Что делает это приложение? Я не особо знаю: я не запускал его самостоятельно и, честно говоря, в коде не так много комментариев, поэтому и правда стоит приглядеться к коду и разобраться. Лучшее, что я мог предположить - это то, что оно воспроизводит схожую с фонтаном анимацию, в которой случайные точки взлетают вверх и вылетают вовне экрана, подобно потокам воды в фонтанах. Анимация запускается когда пользователь прикасается к экрану, взяв эту точку прикосновения за отправную. Это то что я предполагаю, основываясь на исходном коде примера.

Хорошо, так как же всё-таки выглядит код? Сперва давайте взглянем на файлы и на то, как они упорядочены. Структура такова:

 * `Android.mk`
 * `AndroidManifest.xml`
 * `res`
   * `drawable`
     * `gadgets_clock_mp3.png`
   * raw
     * `fountain.c`
 * `src`
     * `com/android/fountain`
       * `Fountain.java`
       * `FountainRS.java`
       * `FountainView.java`

Большая часть из того, что мы видим - это привычное нам приложение для Android: у нас присутствуют основные android-файлы такие как `AndroidManifest`. Потом, у нас есть каталог `src`, в нём хранятся исходные файлы приложения; и ещё у нас есть каталог `res`, ничего особенного поскольку он содержит каталоги `drawable` и `raw`... но, как вы можете заметить, каталог `raw` содержит один очень интересный и вполне себе особенный файл, и имя ему `fountain.c`. Вот где, похоже, покоится код на Renderscript, пусть имя файла и пытается навязать нам, что это файл с исходниками на C. Давайте же взглянем на то, что содержится в этом файле:

``` cpp

// Fountain test script
#pragma version(1)

int newPart = 0;

int main(int launchID) {
    int ct;
    int count = Control->count;
    int rate = Control->rate;
    float height = getHeight();
    struct point_s * p = (struct point_s *)point;

    if (rate) {
        float rMax = ((float)rate) * 0.005f;
        int x = Control->x;
        int y = Control->y;
        char r = Control->r * 255.f;
        char g = Control->g * 255.f;
        char b = Control->b * 255.f;
        struct point_s * np = &p[newPart];

        while (rate--) {
            vec2Rand((float *)np, rMax);
            np->x = x;
            np->y = y;
            np->r = r;
            np->g = g;
            np->b = b;
            np->a = 0xf0;
            newPart++;
            np++;
            if (newPart >= count) {
                newPart = 0;
                np = &p[newPart];
            }
        }
    }

    for (ct=0; ct < count; ct++) {
        float dy = p->dy + 0.15f;
        float posy = p->y + dy;
        if ((posy > height) && (dy > 0)) {
            dy *= -0.3f;
        }
        p->dy = dy;
        p->x += p->dx;
        p->y = posy;
        p++;
    }

    uploadToBufferObject(NAMED_PartBuffer);
    drawSimpleMesh(NAMED_PartMesh);
    return 1;
}

```

Да, очень смахивает на C. Есть структуры, указатели и символы. Начнём с первых строк файла. Есть некий класс или структура `Control`, из которой мы получаем информацию количестве и частоте распостранения частиц, а также значения `x`,`y` и `r`,`g`,`b`. Но где же создаётся структура `Control`? Я вернусь к этому вопросу. Другая структура, которая используется в коде - это `point_s`. Эта структура тоже содержит координаты `x` и `y`, значения `r`,`g`,`b`, которые, скорее всего представляют собой красный, зелёный и синий компоненты цвета, и значение `a` которое является величиной прозрачности (`alpha`). Без дополнительной информации я не могу точно сказать, что происходит в этом коде, но я предполагаю, что скорее всего на основе переданного массива точек создаётся массив новых точек, и всё это чтобы создать какую-то анимацию.

Если мы посмотрим на каталог `src` с исходными кодами - там у нас лежат три файла `.java`. `Fountain.java`, `FountainView.java` и `FountainRS.java`. `Fountain.java` - это обычный потомок `Activity`, который в методе `onCreate` устанавливает `contentView` в экземпляр `FountainView`. Исходный код файла `FountainView.java` выглядит так:

``` java

/*
 * Copyright (C) 2008 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.fountain;

import java.io.Writer;
import java.util.ArrayList;
import java.util.concurrent.Semaphore;

import android.renderscript.RSSurfaceView;
import android.renderscript.RenderScript;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.KeyEvent;
import android.view.MotionEvent;

public class FountainView extends RSSurfaceView {

    public FountainView(Context context) {
        super(context);
        //setFocusable(true);
    }

    private RenderScript mRS;
    private FountainRS mRender;

    private void destroyRS() {
        if(mRS != null) {
            mRS = null;
            destroyRenderScript();
        }
        java.lang.System.gc();
    }

    public void surfaceChanged(SurfaceHolder holder, int format, int w, int h) {
        super.surfaceChanged(holder, format, w, h);
        destroyRS();
        mRS = createRenderScript(false, true);
        mRender = new FountainRS();
        mRender.init(mRS, getResources(), w, h);
    }

    public void surfaceDestroyed(SurfaceHolder holder) {
        // Surface will be destroyed when we return
        destroyRS();
    }



    @Override
    public boolean onTouchEvent(MotionEvent ev)
    {
        int act = ev.getAction();
        if (act == ev.ACTION_UP) {
            mRender.newTouchPosition(0, 0, 0);
            return false;
        }
        float rate = (ev.getPressure() * 50.f);
        rate *= rate;
        if(rate > 2000.f) {
            rate = 2000.f;
        }
        mRender.newTouchPosition((int)ev.getX(), (int)ev.getY(), (int)rate);
        return true;
    }
}

```

Класс `FountainView` - это вид (`View`) в контексте понятий Android. Как вы можете увидеть из кода, `FountainView` наследуется от нового подтипа видов по имени `RSSurfaceView` (**Пер.:** RSS тут не при чём, не запутайтесь). У него также есть ссылки на экземпляры классов `RenderScript` и описанного нами `FountainRS`. При создании новой поверхности (`surface`) в методе `surfaceChanged` кроме прочего создаются эти экземпляры и устанавливаются соответствующие ссылки. Здесь же мы вызывам метод `init` класса `FountainRS` и передаём несколько аргументов, включая ссылку на объект `RenderScript`. Так что давайте, наконец, посмотрим на файл `FountainRS.java`:

``` java

/*
 * Copyright (C) 2008 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.fountain;

import android.content.res.Resources;
import android.renderscript.*;
import android.util.Log;


public class FountainRS {
    public static final int PART_COUNT = 20000;

    static class SomeData {
        public int x;
        public int y;
        public int rate;
        public int count;
        public float r;
        public float g;
        public float b;
    }

    public FountainRS() {
    }

    public void init(RenderScript rs, Resources res, int width, int height) {
        mRS = rs;
        mRes = res;
        initRS();
    }

    public void newTouchPosition(int x, int y, int rate) {
        if (mSD.rate == 0) {
            mSD.r = ((x & 0x1) != 0) ? 0.f : 1.f;
            mSD.g = ((x & 0x2) != 0) ? 0.f : 1.f;
            mSD.b = ((x & 0x4) != 0) ? 0.f : 1.f;
            if ((mSD.r + mSD.g + mSD.b) < 0.9f) {
                mSD.r = 0.8f;
                mSD.g = 0.5f;
                mSD.b = 1.f;
            }
        }
        mSD.rate = rate;
        mSD.x = x;
        mSD.y = y;
        mIntAlloc.data(mSD);
    }


    /////////////////////////////////////////

    private Resources mRes;

    private RenderScript mRS;
    private Allocation mIntAlloc;
    private SimpleMesh mSM;
    private SomeData mSD;
    private Type mSDType;

    private void initRS() {
        mSD = new SomeData();
        mSDType = Type.createFromClass(mRS, SomeData.class, 1, "SomeData");
        mIntAlloc = Allocation.createTyped(mRS, mSDType);
        mSD.count = PART_COUNT;
        mIntAlloc.data(mSD);

        Element.Builder eb = new Element.Builder(mRS);
        eb.addFloat(Element.DataKind.USER, "dx");
        eb.addFloat(Element.DataKind.USER, "dy");
        eb.addFloatXY("");
        eb.addUNorm8RGBA("");
        Element primElement = eb.create();


        SimpleMesh.Builder smb = new SimpleMesh.Builder(mRS);
        int vtxSlot = smb.addVertexType(primElement, PART_COUNT);
        smb.setPrimitive(Primitive.POINT);
        mSM = smb.create();
        mSM.setName("PartMesh");

        Allocation partAlloc = mSM.createVertexAllocation(vtxSlot);
        partAlloc.setName("PartBuffer");
        mSM.bindVertexAllocation(partAlloc, 0);

        // All setup of named objects should be done by this point
        // because we are about to compile the script.
        ScriptC.Builder sb = new ScriptC.Builder(mRS);
        sb.setScript(mRes, R.raw.fountain);
        sb.setRoot(true);
        sb.setType(mSDType, "Control", 0);
        sb.setType(mSM.getVertexType(0), "point", 1);
        Script script = sb.create();
        script.setClearColor(0.0f, 0.0f, 0.0f, 1.0f);

        script.bindAllocation(mIntAlloc, 0);
        script.bindAllocation(partAlloc, 1);
        mRS.contextBindRootScript(script);
    }

}

```

Я не буду подробно рассматривать каждую строчку этого файла но, похоже, самые интересные вещи находятся в функции `initRS`. Там у нас есть построитель элементов (`element builder`), построитель простейших моделей (`Simple Mesh builder`) и последнее, но совсем не маловажное - у нас есть _построитель скриптов_ (`script builder`). Мы получаем экземпляр скрипта, связав его с файлом `fountain.c` и устанавливаем необходимые типы, такие как `Control` и `point` (помните, они использовались в файле `fountain.c`?), а затем создаём и привязываем к контексту сценарий (**Пер.:** как видно, скрипт компилируется во время исполнения Java-кода).


Ну, вот оно и есть - быстрый взгляд на то, как должен использоваться Renderscript. Всё ещё остаётся множетсво неотвеченных вопросов, и много остаётся ещё изучить о том как может, и как сможет, работать Renderscript, но я надеюсь что эти несколько выдержек из кода дадут, по крайней мере, людям начальную точку. Ну и как всегда, если ещё кто-то [в этом мире] знает какие-либо интересные подробности или комментарии, я бы был очень заинтересован [их услышать](http://www.inter-fuser.com/2009/11/android-renderscript-more-info-and.html#comment-form).
