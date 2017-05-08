---
layout: post.html
title: 10 Useful Solutions for Android Developer
datetime: 09 Jan 2010 11:42
tags: [ java, android ]
---

This post contains several useful solutions for Android developers. If you are starting to dive in it, I think the detailed description of the problems I solved will help you in your Android adventures.

### Contents

  1. Introduction
  2. About list adapters with sections (to group elements in the lists)
  3. About lists containing some actions (list elements do something complex or change themselves when selected)
  4. About list views manual invalidation
  5. About caching images in `ListView` (for lists with remote images)
  6. About adapters that iterate over cursors (to support pagination in lists)
  7. About OAuth autorization in Android
  8. About using `MediaPlayer` to play remote video received using HTTP
  9. About queues containing several `AsyncTask`s (to execute background tasks sequentially)
  10. About changing the list element selection style
  11. About adding [QuickActions](http://www.londatiga.net/it/how-to-create-quickaction-dialog-in-android/) to your project
  12. Three more mini-solutions

### 1. Introduction

Last summer I had ignited the desire to write an Android client for [vimeo](http://vimeo.com) web-service. I like this service and I think it would be cool to monitor updates on video subscriptions from your communicator.

I сonceived [this project](http://code.google.com/p/vimeoid) to be learning one (means I am learning), however as a result I've found that a valuable part was done (you can check out [screenshots of the finished things](http://code.google.com/p/vimeoid/wiki/Screenshots)), but it is still in progress. Almost simultaneously with me, being first, [makotosan](http://vimeo.com/makotosan) started to write his [own version](http://www.androlib.com/android.application.com-makotosan-vimeodroid-qmBCn.aspx) of client aimed at video upload and he is also has not finished it yet, but his version can do things that my version can not (and converse is also true, seems).

Anyway, through programming process I've got some knowledge base which I want to share. Not all the themes are exclusive but some tricks are hidden in the web or even not covered there. _I will also give examples from vimeoid source code, so it will allow you to spy how the paragraph subject works in real-time_ (*NB*: some achors point to concrete lines in code).

### 2. Lists with subsections

Among with the regular `ListView` usage, it is frequently required to make a list with elements grouped in sections like this: section header, item, item, item, ..., section header, item, item, item, ..., section header, item, item, ..., section header, item, item, ... & s.o. See "Statistics" and "Information" sections at the image.

![List with sections]({{ get_figure(slug, 'guest-channel.png') }})

Headers must not react on selection or press and they must have their own layout. This may be accomplished extending the adapter of this list from `BaseAdapter`, for example, and by overriding its `getItemViewType`, `getViewTypeCount` and `isEnabled` methods, among with `getView`.

``` java

public class SectionedItemsAdapter extends BaseAdapter { . . .

```

* Example from vimeoid: [`SectionedActionsAdapter`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/adapter/SectionedActionsAdapter.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

The first step is creating a constants which identify element type, one for header, one for item (so there is a possibility to have more than two types, but it's better to use `enum` to store idenitifiers in cases like those):

``` java

public static final int ITEM_VIEW_TYPE = 0; // item
public static final int SECTION_VIEW_TYPE = 1; // section

```

Then a constant containing a number of element types (there's two in our case):

``` java

public static final int VIEW_TYPES_COUNT = SECTION_VIEW_TYPE + 1;

```

Adapter must contain the information about all of the elements inside, so the `getCount`, `getItem` and `getItemId` realizations are depend on your situation.

`getItemViewType` method must return the constant that conforms with the element type in the passed position. There is a special constant named `IGNORE_ITEM_VIEW_TYPE` exist in `Adapter` class for the case when type is undefined.

``` java

public int getItemViewType(int position) {
    if (. . .) return ITEM_VIEW_TYPE;
    if (. . .) return SECTION_VIEW_TYPE;
    return IGNORE_ITEM_VIEW_TYPE;
}

```

I my case I store the list of sections inside the adapter and they contain their items inside. So I can ask any section to tell me how many items it holds inside and to determine the element type using this data.

This method can be used in overriden `getView` now:

``` java

public View getView(int position, View convertView, ViewGroup parent) {
    final int viewType = getItemViewType(position);
    if (viewType == IGNORE_ITEM_VIEW_TYPE) throw new IllegalStateException("Failed to get object at position " + position);
    if (viewType == SECTION_VIEW_TYPE) {
        convertView = . . . // here you can get a header layout using LayoutInflater
    } else if (viewType == ITEM_VIEW_TYPE) {
        convertView = . . . // here you can get an item layout using LayoutInflater
    }
    return convertView;
}

```

`isEnabled` must return `false` for elements that can not be pressed or selected and `true` for others. Here we can use `getItemViewType` again:

``` java

public boolean isEnabled(int position) {
    return getItemViewType(position) != SECTION_VIEW_TYPE };

```

`getViewTypeCount` method returns the very constant determing a number of elements types:

``` java

public int getViewTypeCount() { return VIEW_TYPES_COUNT; }

```

By the way, you can keep a pointer to `LayoutInflater` in your adapter and get it passed using constructor.

It is all the required things to make a list with sections, if you need to ensure in something - just look into example, but I'll make some notices before.

I use separate structures to store the data about sections and items. The section identifier, its title and child items structures are stored within the section structure. A pointer to parent section structure, item title, icon path and click handler (it will be covered in next paragraph) are stored within the item structure. Both structures' constructors are accessible only from adapters:

* Example from vimeoid: [`LActionItem`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/adapter/LActionItem.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

I simplified adding sections and items to list using this way. Adapter has methods:

``` java

public int addSection(String title);
public LActionItem addItem(int section, int icon, String title);

```

Method `addSection` returns the section identifier so you can use it to add items in this section:

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

### 3. Lists with elements that react on something

Sometimes it is required to change the list element content and/or switch activity when it is clicked. For example, the list of possible actions with some twitter account may contain "follow" element with minus icon, if you still do not follow this man and change its icon to plus when click happened and positive response (to following request) is received from twitter server. You can handle the selected element in current `ListActivity` and depending on position take a decision, but if your list is inside the general `Activity`, so may be it will be easier to handle selection inside the adapter.

 * Example from vimeoid: [`SectionedActionsAdapter`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/adapter/SectionedActionsAdapter.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Uses: [`LActionItem`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/adapter/LActionItem.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Used in: [`SingleItemActivity_`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/base/SingleItemActivity_.java?r=85e18485bdda1c526141170f67e65f4e00202f34#49)

If you agree with that, your adapter can implement `OnItemClickListener` interface:

``` java

public class ActionsAdapter extends . . . implements OnItemClickListener

```

And inside the activity that uses this adapter you can do:

``` java

final ListView actionsList = (ListView)findViewById(R.id.actionsList);
final SectionedActionsAdapter actionsAdapter = new ActionsAdapter(. . .);
. . . // fill adapter with values
actionsList.setAdapter(actionsAdapter);
actionsList.setOnItemClickListener(actionsAdapter);

```

In my case some actions are responsible for each item in the section - they switch the activity or change the corresponding item content after server request. So I decided to create structures with public-access properties for sections and items, and the item structures contain a pointer to `OnClick` handler that gets `View` to change, so you it is possible to change the view just inside the handler. So it is just required to pass a click action to the appropriate handler inside the adapter:

``` java

public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
    final LActionItem item = (LActionItem) getItem(position);
    if (item.onClick != null) item.onClick(view);
}

```

Using the `addItem` method described above you can set a handler directly from activity:

``` java

final LActionItem heartsItem = adapter.addItem(suitsSection, R.drawable.heart, "Hearts");
heartsItem.onClick = new OnClickListener() { public void onClick(View view) { . . . } };

```

### 4. Manual invalidation of list views

As you may know, `ListView` in Android has a [little trick inside] named [_ListView Recycler_](http://android.amberfog.com/?p=296). Its principle is in reusage of old elements views for elements that not fit the screen instead of creating new views while user scrolls the list like this, this principle is used in adapters' `getView` implementations.

If you need to update (invalidate) concrete known element view (or even its child view) at some moment, when it is visible to user, you may call `ListView.invalidate()` or `Adapter.notifyDataSetChanged()`, but sometimes these methods update not only the required view but also its neighbours or even all the visible elements (especially when layout is [built incorrectly](http://www.curious-creature.org/2009/02/22/android-layout-tricks-1/)). There is a way to get the current view of list element using `ListView.getChildAt(position)` method. But `position` in this case is not index of the element in a list, as you may considered, but an index relative to visible views on the screen. So a methods like these would help:

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

`invalidateByPos` updates view only if it is shown on the screen (forcing an adapter's `getView` method call), if this element is not visible - adapter's `getView` will be called automatically when this view will appear to user after scrolling. To update some child view of an element, you can use `getViewIsVisible` method, it will return the element view which gives access to its child views and it returns `null` if this element is not visible so update is not required.

 * Methods are defined in class: [`Utils`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/util/Utils.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

### 5. Caching remote images for lists

![List with remote images]({{ get_figure(slug, 'guest-videos.png') }})

If you are creating `ListView` containing images taken from web, this chapter is for you. It would be unwise to get images by URL again each time `getView` is called in adapter - it is obvious that it would be better to a) cache them b) ask for them only when view with this image is visible. For the moment this task arose so recently for Android programmers, so there are a lot of [solutions for it](http://stackoverflow.com/questions/541966/android-how-do-i-do-a-lazy-load-of-images-in-listview).

My variant is also from that list, it is [Fedor Vlasov](http://stackoverflow.com/questions/541966/android-how-do-i-do-a-lazy-load-of-images-in-listview/3068012#3068012)'s solution, that is corrected for my needs. First, I changed a directory for cached images to be static, so it is created once for application cycle and surely cleaned when calling `clearCache` (it is good to call this method in `onDestroy()` of `Activity` using `ImageLoader` or in `finalize()` method of adapter using it), also I've changed a bit a way of this directory creation (see `Utils.createCacheDir()`). Secondly, you may pass the drawables IDs to constructor to determine what drawables to show in this place while loading an image and/or if loading image is failed. Thidly, some minor changes. Though, this class can be a singleton and you can just change its options before using it, but it is left for your decision. In my case the instance is created for each `ListActivity` started and is passed to adapters of inner `ListView`s that need it (or created directly in adapters if `ListView`s are inside a regular `Activity`). The main method id `displayImage(String url, ImageView view)`, its definition speaks for itself.

 * Source from vimeoid: [`ImageLoader`](http://code.google.com/p/vimeoid/source/browse/apk/src/com/fedorvlasov/lazylist/ImageLoader.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Uses methods from: [`Utils`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/util/Utils.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

### 6. Adapters iterating over cursors

This chapter is about pagination in `ListView`. So, user gets first `n` elements, scrolls list to `n`-th element and only after that happen the response for `n` elements to DB or server is performed. Then the user scrolls the element `2n` and we ask for next package with `n` size and so on. In _vimeoid_ I make a resonse only after `footerView` with 'Load more...' label is clicked, it is not automatic way, but the technique is similar to subject.

 * Loading by click on `footerView`: [`ItemsListActivity_`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/base/ItemsListActivity_.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Guest implementation: [`ItemsListActivity`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/guest/ItemsListActivity.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Logged-in user implementation: [`ItemsListActivity`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/user/ItemsListActivity.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

The classes hieararchy is a lit bit more complex, each page is loaded with special `AsyncTask` that calls Vimeo API in background and notifies the calling activity about are there any elements left or is it the last page, and the activity updates its views according to this data.

 * Adapter containing a set of cursors: [`EasyCursorsAdapter`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/adapter/EasyCursorsAdapter.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

To make a pagination possible, you may just keep a set of page containers (cursors, for example) in adapter and in `getView()`, if one of last elements is asked for, run the query for next page (`AsyncTask` is preferred), which will add new container to adapter when it will be received, so the adapter will have a possibility to call `notifyDataSetChanged()`. Like this:

``` java

private final Page[] pages = new Page[MAX_PAGES_COUNT];

public View getView(final int position, View convertView, ViewGroup parent) {

    if (!waitingNextPage &&
        (pages.length < MAX_PAGES_COUNT) &&
        (position >= ((pages.length * PER_PAGE) - 2))) {

        final AsyncTask<Integer, . . .> nextPageTask = . . .;
        nextPageTask.execute(pages.length);
        // nextPageTask calls addSource, when next page is received

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

`EasyCursorsAdapter` is a good example for a case where `Cursor` is `Page` analogue. I am sure there are several alternative solution exists and I will be glad if someone will mention them in comments.

### 7. OAuth in Android

If you are writing a client for a complex web-service - you need to fight with authorization problem and in current moment most web-services use [OAuth](http://en.wikipedia.org/wiki/OAuth) for its realization and Vimeo is one of those.

There is no need to write your own implementation of OAuth, there is very cool library named [signpost](http://code.google.com/p/oauth-signpost/) exist, and I do not know any better alternatives for now.

 * Example from vimeoid: [`VimeoApi`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/connection/VimeoApi.java?r=85e18485bdda1c526141170f67e65f4e00202f34#101)
 * Uses signpost through: [`JsonOverHttp`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/connection/JsonOverHttp.java?r=85e18485bdda1c526141170f67e65f4e00202f34#164)
 * Activity that gets user token: [`ReceiveCredentials`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/ReceiveCredentials.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Its definition at manifest: [`AndroidManifest.xml`](http://code.google.com/p/vimeoid/source/browse/apk/AndroidManifest.xml?r=85e18485bdda1c526141170f67e65f4e00202f34#22)

To start, you need to get the exclusive key for your application from web-service and set a callback URL to return user there after successful authorization (i.e. `vimeoid://oauth.done`) (but in case of Android, tou can pass it with call to `/request_token`). Recently it is done using service web-interface for programmer.

The first authorization algorythm for Android is:

 1. Point signpost to a service's OAuth entry-points
 1. Send a request to `/request_token`, get a token/secret pair using this key for unauthorized requests of your applization (`vimeoid://oauth.done` callback URL is passed here): `provider.retrieveRequestToken(Uri callbackUri)`. *NB:* `retrieveRequestToken` returns not token but `Uri` that you need to call in next step at once.
 1. Launch browser activity, call `/authorize` with passing the application token and, optionally, appending additional parameters about required access rights: `startActivity(new Intent(Intent.ACTION_VIEW, authUri + ...))`
 1. User will see a page in 'Allow this application to access your account?' style (if he is logged out of service, service will ask him to log in). If user grants access, browser will be redirected to callback URL `vimeoid://oauth.done?...`, but in case in your `AndroidManifest.xml` there is a special activity to handle URLs like this, Android will return a user to your application and open this very activity - `ReceiveCredentials`.
 1. In `ReceiveCredentials` activity you get user token in parameters `Uri uri = getIntent().getData()`, now you need to get secret using this token by requesting `/access_token`: `provider.retrieveAccessToken(Uri uri)`.
 1. Now you can save user's token and secret in private `SharedPreferences`, for example: `consumer.getToken()`, `consumer.getTokenSecret()`.

After all these things done you can just sign every request to web-service API with the token/secret you've got: `consumer.sign(Object request)`. If your application was restarted, before doing any request you can check if you have saved tokens in `SharedPreferences`, if you are - just remember `signpost` with them: `consumer.setTokenWithSecret(String token, String secret)`, in not - request access token again (or just refresh tokens, if web-service allows it).

Important notice: signpost in Android works only with `CommonsHttpOAuthConsumer`/`CommonsHttpOAuthProvider`. `DefaultOAuth*` classes do not work.

### 8. Getting video by HTTP and playing it in MediaPlayer

It is very hard to make [`MediaPlayer`](http://developer.android.com/reference/android/media/MediaPlayer.html) do the things you want in case of playing video, as I discovered. To get a video it was required for me to make an unusual HTTP request with special headers, so I had to implement getting stream and its buffering manually. I could not get stream playing using the [audio-files-related examples](http://blog.pocketjourney.com/2009/12/27/android-streaming-mediaplayer-tutorial-updated-to-v1-5-cupcake/) as a pattern, so I download the full video file and start playing just when downloading is finished (if there will be not enough space to get video on SD card, I warn user about it). When player is closed or failed to play, I clear the cache.

Moreover, `VideoView`/`SurfaceView` behavior works ambiguously when switching views inside one single layout (black screen from time to time), so I had to just leave a single `VideoView` in layout and show  `ProgressDialog` on the top of it, while video is loading. Again, if you know something about stream playing videos using `MediaPlayer` (or getting chunks manually), write to comments.

So, if there is enough to call `MediaPlayer.setDataSource(Uri uri)` in your case, you can skip some next paragraphs.

And if you also had to get a stream manually, I will notice a few moments and just demonstrate the code, it must speak for itself:

  * Example from vimeoid: [`VimeoVideoPlayingTask`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/media/VimeoVideoPlayingTask.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
  * Called from activity: [`Player`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/Player.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
  * Layout: [`player.xml`](http://code.google.com/p/vimeoid/source/browse/apk/res/layout/player.xml?r=85e18485bdda1c526141170f67e65f4e00202f34)

It is better to get a stream using `AsyncTask`. I just aggregate `MediaPlayer` with `...PlayingTask` for convenience, you may use any other way you want, but definitely it is better to get a stream using `AsyncTask`.
In this case in `onPreExecute` method you may set up yout player, in `doInBackground` you can get a video stream and return it to `onPostExecute` and start playing from there. Also, it is handy to show percentage progress of downloading, because you know an amount of data received in `doInBackground`.

And if there is an exception was raised while getting a stream, it is required to show a message about in using `runOnUiThread`, because task execution was interrupted.

Calling `getWindow().setFormat(PixelFormat.TRANSPARENT);` is aimed to prevent views shown above the player to stay above even when they are closed/hidden. Anyway, when it is required to use `ViewSwitcher`, this stuff do not helps.

Code to get video stream by URL is similar to this one:

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

### 9. AsyncTask Queues

If you need to execute several background tasks sequentially (when one finished - run next), this freestyle pattern (walking by linked list inside) will fir you. For example when your activity started you need to perform several successive calls to some web-server API or database. The main thing is that parameters and result types for all these tasks must be similar.

Here is a task-that-knows-it-has-next-task inteface:

``` java

public interface HasNextTask<Params> {
    public int getId();
    void setNextTask(HasNextTask<Params> task);
    public HasNextTask<Parames> getNextTask();
    public AsyncTask<?, ?, ?> execute(Params... params);
                      // must much with AsyncTask<Params, ...>
}

```

Here is an interface that monitors when tasks are performed successfully or not:

``` java

public interface PerformHandler<Params, Result> {
    public void onPerfomed(int taskId, Result result, HasNextTask<Params> nextTask);
    public void onError(Exception e, String description);
}

```

`HasNextTask` interface implementation. The hollows given with three dots, you may move them into child class or make this class abstract to implement `doInBackground`/`onPostExecute` methods right in `createTask` method of queue:

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
    public Result doInBackground(Params... params) { . . . /* task execution */ }

    @Override
    protected void onPostExecute(Result result) {
        . . . // handling a result, if required
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

And the main thing, the queue implementation:

``` java

public abstract class TasksQueue<Params, Result>
                implements PerformHandler<Params, Result>, Runnable {

    public static final String TAG = "TasksQueue";

    private HasNextTask<Params> firstTask = null;
    private HasNextTask<Params> lastTask = null;
    private Map<Integer, Params> tasksParams = null;
    private int currentTask = -1;
    private boolean running = false; // some task is running now
    private boolean started = false; // the whole queue is running now
    private int size = 0;

    protected HasNextTask<Params> createTask(int taskId) { // can be overriden
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

Now in your activities you can easily create a queue of background tasks:

``` java

protected final TasksQueue secondaryTasks;

private final int TASK_1 = 0;
private final int TASK_2 = 1;
private final int TASK_3 = 2;

public ...Activity() { // constructor

    secondaryTasks = new TasksQueue<..., ...>() {

        // here you can override createTask

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

By the way, thanks to `Runnable` interface you can run queues like this in separate thread:

``` java

new Thread(secondaryTasks, "Tasks Queue").start();

```

 * Tasks queue in vimeoid: [`ApiTasksQueue`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/user/ApiTasksQueue.java?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Created in: [`SingleItemActivity`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/user/SingleItemActivity.java?r=85e18485bdda1c526141170f67e65f4e00202f34#49)
 * Filled with tasks in: [`UserActivity`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/user/item/UserActivity.java?r=85e18485bdda1c526141170f67e65f4e00202f34#122)
 * Handling completed tasks in: [`UserActivity`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/user/item/UserActivity.java?r=85e18485bdda1c526141170f67e65f4e00202f34#301)

### 10. ListView selection highlight

![Selected element in list]({{ get_figure(slug, 'user-video.png') }})

You see a blue line on the image, it is a custom selected element highlight and it has four conditions - pressed, focused, disabled and transition animation from pressed to held condition for long tap. First three and held condition - it is so-called `9-patch`, sure you [heard something about them](http://developer.android.com/guide/developing/tools/draw9patch.html), animation is an `xml`-file.

To define the states for selection highlight, set `android:listSelector="@drawable/selector_bg"` for your `ListView` in layout. The algorythm is simple, but it to build rules in proper order in not an easy task sometimes. See examples:

 * Definition: [`selector_bg.xml`](http://code.google.com/p/vimeoid/source/browse/apk/res/drawable/selector_bg.xml?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Animation: [`selector_bg_transition.xml`](http://code.google.com/p/vimeoid/source/browse/apk/res/drawable/selector_bg_transition.xml?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Declared at: [`generic_list.xml`](http://code.google.com/p/vimeoid/source/browse/apk/res/layout/generic_list.xml?r=85e18485bdda1c526141170f67e65f4e00202f34#16)

![9-patch editor]({{ get_figure(slug, 'draw9patch-norm.png') }})

There are also a tricks with 9-patch, each time when there is something wrong in layout, the whole list becomes a mess. Main rule is to check `ListView` declaration first of all, ensure that `layout_width` and `layout_height` are set to `fill_parent` and re-check the parent elements higher in the hierarchy. Then, if it has not helped, you may try to correct 9-patches. The thick black lines on top and to the left determine what image areas will be stretched if the content can't fill the image. The thick black lines (optional) on bottom and to the right determine in what image area the content will fit itself. It is also not so easy to get the correct positions at first time, have to experiment. Don't even think about creating 9-patches without editor, it is a brainfuck - content areas and errors are highlighted in editor, but even when everything seems ok, inflater understands a layout as you expect not every time.

![Disabled state]({{ get_figure(slug, 'selector_bg_disabled.9.png') }}) ![Focused state]({{ get_figure(slug, 'selector_bg_focus.9.png') }}) ![Pressed state]({{ get_figure(slug, 'selector_bg_pressed.9.png') }}) ![Held state]({{ get_figure(slug, 'selector_bg_longpress.9.png') }})

### 11. Adding QuickActions

![QuickActions example]({{ get_figure(slug, 'user-videos.png') }})

[QuickActions](http://www.londatiga.net/it/how-to-create-quickaction-dialog-in-android/) - is small library for the popping out dialogs with actions like the one shown on the picture (and not just like this, because the design can be changed freely). They became a new trend when official twitter-client appeared. Sure there are another implemantations exists but in _vimeoid_ I use this one and also changed it a bit for my needs.

To show a dialog like this instead of context menu when element in list is long-tapped, it is enough to override `onCreateContextMenu` method in `ListActivity` like this:

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

 * Directory contating a modified version of a library [`lib-qactions`](http://code.google.com/p/vimeoid/source/browse/lib-qactions?r=85e18485bdda1c526141170f67e65f4e00202f34)
 * Used in: [`VideosActivity`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/activity/user/list/VideosActivity.java?r=85e18485bdda1c526141170f67e65f4e00202f34#113)

Adding external library to Eclipse project is described [in this article](http://developer.android.com/guide/developing/eclipse-adt.html#libraryProject). To be short, it is enough to create the separate Android project with sources for a library, set `isLibrary` checkbox in `Android` section in project properties, and in the original project just add the library project using `Library` -> `Add` button from the same section. `R`-file from the library project will be added to the original project after rebuild.

### 12. Three additional mini-solutions

#### 12a. One entry point to invoke different activities

If your application uses a lot of different activities that called similar way, may be it will be useful for you to move this calls to a separate class, including filling `Extras` with data:

 * Example from vimeoid: [`Invoke`](http://code.google.com/p/vimeoid/source/browse/apk/src/org/vimeoid/util/Invoke.java?r=85e18485bdda1c526141170f67e65f4e00202f34)

#### 12b. Placeholders in localization strings

My be it is obvious, but in strings from `strings.xml` you can use placeholders to insert some locale-independent values inside these strings, i.e.: `<string name="image_info">Image size: {width}x{height}</string>`. `format` function can help you like this: `format(getString(R.string.image_info), "width", String.valueOf(600), "height", String.valueOf(800))`

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

**Upd.** As I expected, I had missed this method in Android library: there is a standard function [`getString(int resId, Object... formatArgs)`](http://developer.android.com/intl/de/reference/android/content/Context.html#getString%28int,%20java.lang.Object...%29). Thanks to [zochek](http://zochek.habrahabr.ru/).

#### 12c. About wrong layouts

Be sure to read these articles, inflater in Android is very sensitive to complicated structures and if you are writing a complex application, you'll have to fix your layouts sooner or later:

 * [Layout Tricks #1](http://www.curious-creature.org/2009/02/22/android-layout-tricks-1/)
 * [Layout Tricks #2](http://www.curious-creature.org/2009/02/25/android-layout-trick-2-include-to-reuse/)
 * [Layout Tricks #3](http://www.curious-creature.org/2009/03/01/android-layout-tricks-3-optimize-part-1/)
 * [Layout Tricks #4](http://www.curious-creature.org/2009/03/16/android-layout-tricks-4-optimize-part-2/)
 * [Speed up your Android UI](http://www.curious-creature.org/2009/03/04/speed-up-your-android-ui/)

My frequently re-rendedered layouts in one moment collapsed and `getView` has called approximately once per second (and I also meet this case now, but in much rare moments). After replacing a lot of nested complicated  `LinearLayout`s to less-nested and elegant `RelativeLayout`, inflater clearly felt itself easier and me too, mysefl, because a hierarchy also became less complicated and it became easier to make changes. I do not had time to fix all of these, but now I am more attentive to layouts. Also check that you use `width/height=wrap_content` only for simple elements if possible, using `wrap_content` for width/height of `LinearLayout`s and other compound views is dangerous and may lead to unexpected consequences. It may not lead, but who is forewarned...
