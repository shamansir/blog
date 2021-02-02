---
layout: post.html
title: "PureScript: UI driven by Finite State Machines and Event Streams"
datetime: 07 Apr 2020 13:01
tags: [ purescript, functional-programming ]
excerpt: Building UIs as state machines is not a new approach, and may appear common to a reader by some other names. Still, in PureScript, with it's freedom to choose any approach you like, it may seem not to come to head as a first thought, or even second one. Usually one may just use some framework. This post is about what could be behind your framework and for those who want to consider different ways to write UI by hand in PureScript. As the title says, plus accumulating errors and recovering to the latest successful state.
---


I should've call the article _”The Elm Architecture in PureScript”_, but both the inner demons and the inner angels said "Oh, dear, no!". Still I can't deny the article covers such topic as well.

Among that, this article covers the easiest way for accumulating errors and recovering to the last successful state of the application in a flick of the wrist (I love [that song](https://www.youtube.com/watch?v=mrApaXj5QmA)).

Also I plan to abandon explaining why I chose PureScript and get straight to the details. Just keep in mind that Haskell and PureScript are bro-s: each one is pretending to be radically different, but they share truly a lot of common.

The project I am working on, _Noodle_, has quite complex UI and API as well. For some time I struggled in finding the proper architecture to define both of them, because my intuition strictly said there are common patterns I am yet too blind to see. In pure functional languages it is really easy to write some shitty code, just not making it public, and reason about it later, while you have everything working and stable. And not to confuse you with the harsh word _shitty_, I have a bunch of unit tests to ensure the logic is what I expect it to be. Also, I think, in leaning to perfection it is important to know where to do a step off the road for some time and get back to this infinite road with new strengths and visions… but enough morals.

When I discovered the article [Finite State Machines in Haskell](https://wickstrom.tech/finite-state-machines/2017/11/10/finite-state-machines-part-1-modeling-with-haskell.html) and read it, everything stood on its place. This was the pattern! Not to oblige you reading the article, the key point is that Finite State Machine is as easy as this function:

```haskell
finiteStateMachine
    :: forall action model
     . action -> model -> model
```

That is our famous _”The Elm Architecture”_ in its essence, simplified to the origins where it was actually born.

The function, which receives some _action_ (say, `DecrementCounter` or `WithdrawMoney` or `JustRobThePlace`), gets _previous model_ and evaluates to the _new modified model_. Some people prefer it flipped, so the model comes as the first argument. Those actions are usually the sum types so it is easy to keep them in one place and have a birds-eye view on the processes happening in your application. [^1]

Let’s move the practical example [to another part of the article](https://dev.to/shamansir/purescript-ui-driven-by-finite-state-machines-and-event-streams-part-ii-the-example-3m77) and for now mostly speak theory. Don’t be confused, in the end of this part I’ll give the complete working code for FSM using FRP, since it’s just a few lines of code. First, we will define the signature, then the way to `make` it and, finally, `run` it.

## Considering Effects

Both the UI and API in my case require some side effects to be performed. For API it’s, for example, generating a random UUID for any new entity. And, since I use FRP events, subscribing to event streams or cancelling them is also a side effect. In case of UI, it is `Event.stopPropagation` (where _event_ is HTML event, not the FRP one), `requestAnimationFrame`, drawing on canvas, some connections to JavaScript using FFI. Some of such effects should be `Aff` though, since they are asynchronous, but it doesn’t really _affect_ what we discuss in any matter.

Separating effects from the pure actions is very important in pure functional languages, still it doesn’t mean you can’t use them, just keep them marked as such and, preferably, sorted (see below).

```haskell
finiteStateMachine
    :: forall action model
     . action -> model -> Effect model
```

In Elm, every `update` function returns `Cmd` along with the model, which is also the wrapper for the effects, still you may need some effort to realise it. Actually, they separate model from the effects, and that’s smart thing to do, so let’s do the same:

```haskell
finiteStateMachine
    :: forall action model
     . action -> model -> model /\ Effect Unit
```

If you ever used the `Spork` library, you may want to draw attention to the fact that they also use a sum type to describe effects. So in my case they would have `NewUUID` and `StopPropagation` constructors for the `effect` type instances and functions like:

```haskell
finiteStateMachine
    :: forall action model effect
     . action -> model -> model /\ List effect

performEffect
    :: forall effect
     . effect -> Effect Unit
```

Where `performEffect` is performed after every call to FSM.  That’s a really good way to sort the effects and don’t put them into one basket. But I decided not to do that in the end: I had such code before and may be I’ll get it back in some form, but during the rewriting stage I wanted not to bother thinking about that, and now I have the working code, which is open to return to this approach, at some point, maybe. Just please notice that it’s really something to think through.

Actually the Elm’s `Cmd` is doing the similar thing by requiring you to provide functions which return specific actions, but more on that later, just in the next chapter.

If you have considered that, let’s get back to the latest specification and stick with it in the end of this section:

```haskell
finiteStateMachine
    :: forall action model
     . action -> model -> model /\ Effect Unit
```

The article on Haskell’s way covers it really well with the examples using `IO`, which is the same concept as `Effect` in PureScript.

## Recursing to Actions

If you are willing to keep actions minimalistic, meaning that each action is modifying the model in one single and predictable way, defined by the name of such action (e.g. not just `RobTheBank`, but rather splitting it into `BuyToyShotgun`, `DefineWorkingHours`, `FindOutSecuritySchedule`, `WearMask`, `EnterTheBank`, `GetToCachier`, `TryNotToPee` and so on, it’s not me to give you details on how to do it, just visit `wikihow.com` on robbing banks), you would see that one action sometimes requires other actions to be performed. Without wearing a mask, it’s better not to start the robbing procedure at all (depends on your case, for sure).

So it becomes handy to return the list of the actions to perform next, which can be empty, of course.

```haskell
finiteStateMachine
    :: forall action model
     . action -> model -> model /\ List action
```

If you are still thinking about Elm, you may recall that `Cmd.batch` thing, which represents effects that are evaluated from `update` function where every effect is bound to the specific action. Let’s also join this concept with the specification of effects we did previously:

```haskell
finiteStateMachine
    :: forall action model
     . action -> model -> model /\ Effect (List action)
```

It could be another way around:

```haskell
finiteStateMachine
    :: forall action model
     . action -> model -> model /\ List (Effect action)
```

This way you can not share data between the effects you perform, only with carrying them together with actions. Which is really a good thing for making things really pure and minimalistic. But I decided to avoid that for the sake of simplicity, still you are always free to choose the proper way by just replacing one with another and make it compile.

I also made some helpers to refrain from typing `pure` in the end of `do`-blocks a lot. If you use `List (Effect action)` technique, you don’t need them, obviously:

```haskell
doNothing :: forall action. Effect (List action)
doNothing = pure []

single :: forall action. action -> Effect (List action)
single = pure <<< List.singleton

batch :: forall action. List action -> Effect (List action)
batch = pure
```

At this point, we are ready to define our data type:

```haskell
data FSM action model =
    FSM (action -> model -> model /\ Effect (List action))
```

Let’s also define the function to create such instances, which is just a type constructor for now, but we leave the opportunity for it to be changed later:

```haskell
make
    :: forall action model
     . (action -> model -> model /\ Effect (List action))
    -> FSM action model
make = FSM
```

That’s actually it! We can represent all other things just with reusing this one.

## Errors, Introducing `Covered`

I have to confess that I am using my own data type to work with errors. As much of you probably did, I researched the problem of accumulating errors (no, I do swear I have no intention [to have separate types for them](https://www.parsonsmatt.org/2018/11/03/trouble_with_typed_errors.html)!) and no solution satisfied me, except this one:

```haskell
data Covered e a
    = Carried a
    | Recovered e a
```

Where `Carried` means we _carry_ the value and it’s all good. And `Recovered` means we had some error and the value was _recovered_ from that failure.  It just always stores the last successful value, along with the error, when it had un-fortune to happen. The single and the latest error, same as for value,.. unless you have `Semigroup e => Covered e a`!

Imagine you are cooking something and if you have forgot to buy some ingredient, you just skip it and happily continue the process, but notice such failure in the list of failures to avoid in the future. Or you broke the eggs together with the eggshells while preparing the cake, so you just suck the eggs and the eggshells back from the stock, and it’s all fine, you just put a notice near the cake that eggshells were there, and the eggs were also required to be reverted due to error, but it’s all clean now, _bon appétit_. Seems I am not that good in examples.

So the FSM, where it is possible to keep the last error (or accumulate errors), looks like this:

```haskell
type CoveredFSM error action model =
    FSM action (Covered error model)
```

But since we need to alter the `update` function behaviour, and it should be imprinted in the logic of such machine, it could be better to make it a data type (and ensure to hide the constructor):

```haskell
data CoveredFSM error action model =
    CoveredFSM (FSM action (Covered error model))
```

Since `Either` is the purest way of dealing with errors, I use it as an atomic part of the API: every function that belongs to the core API and can fail with some error, evaluates to `Either` and nothing else. So does the `update` function that wraps the API, except that _inbetween_ the calls, after the action was applied to the model, it either (no pun intended) replaces `Either` with the `Covered`, holding the previous model (which we always have in `update` function) _or_, if the error type satisfies `Semigroup` typeclass, it glues the errors from the previous call with the ones from the ongoing call.

But first, let’s review the approach where we just store the last error and rollback to a last successful state. For that you’ll need a function that moves the error from one `Covered` instance to another, if there is one. The function is simple:

```haskell
consider
    :: forall e a
     . Covered e a -> Covered e a -> Covered e a
consider (Recovered errA _) (Carried vB) = Recovered errA vB
consider _ coveredB = coveredB
```

It seems to satisfy `Alt` laws (but not `Alternative`), so we may assign the `<|>` operator for it. And this way you can use this function for folding the event streams of `Covered` values, for example.

```haskell
instance coveredAlt :: Alt (Covered e) where
    alt = consider
```

And so we need to define custom `make` function for `CoveredFSM`:

```haskell
make
    :: forall error action model
     . (action
            -> Covered error model
            -> Covered error model /\ Effect (List action))
    -> CoveredFSM action model
make updateF =
    CoveredFSM
        $ FSM.make \action model ->
            let model' /\ effects' = updateF action model
            in (model <|> model') /\ effects'
```

If storing the last error satisfies your needs, you could stop at this point.

If you want to store all the errors happened, you’ll need some function to append errors from one `Covered` instance to another. Let’s call it `appendErrors`—it’s not `Semigroup`’s `append`, since it operates on errors rather than values:

```haskell
appendErrors
      :: forall e a b
     . Semigroup e
    => Covered e a -> Covered e b -> Covered e b
appendErrors (Recovered errorsA _) (Recovered errorsB valB) =
    Recovered (errorsA <> errorsB) valB
appendErrors (Recovered errorsA _) (Carried valB) =
    Recovered errorsA valB
appendErrors (Carried _) coveredB =
    coveredB
```

And it’s update function looks like this:

```haskell
make'
    :: forall error action model
     . Semigroup error
    => (action
            -> Covered error model
            -> Covered error model /\ Effect (List action))
    -> CoveredFSM action model
make' updateF =
    CoveredFSM
        $ FSM.make \action model ->
            let model' /\ effects' = updateF action model
            in (model `appendErrors` model') /\ effects'
```

A trained eye may notice a pattern here: we just have one function that changes the way how we join the previous model with the next one. If it sounds like _folding_ to you, I share your inference. By defining a data type or `newtype` we are ensuring that user uses the proper instance of `CoveredFSM` and don’t forget to specify the way to glue errors. But that doesn’t prevent us from adding a helper to `FSM`, such as:

```haskell
joinWith
    :: forall action model
     . (model -> model -> model)
    -> FSM action model
    -> FSM action model
joinWith joinF (FSM updateF) =
    FSM $ \action model ->
            let model' /\ effects' = updateF action model
            in (model `joinF` model') /\ effects'
```

And now our `make` functions become much fancier:

```haskell
make
    :: forall error action model
     . (action
            -> Covered error model
            -> Covered error model /\ Effect (List action))
    -> CoveredFSM error action model
make =
    FSM.make
        >>> FSM.joinWith ((<|>))
        >>> CoveredFSM

make'
    :: forall error action model
     . Semigroup error
    => (action
            -> Covered error model
            -> Covered error model /\ Effect (List action))
    -> CoveredFSM error action model
make' =
    FSM.make
        >>> FSM.joinWith Covered.appendErrors
        >>> CoveredFSM
```

One of the downsides of using `Covered` could be that it’s not that fancy to use`Covered` in `do`-notation, rather than its brothers `Maybe` and `Either` since (unless you wrap the `Either`-producing function in `Covered` later, as noted above) you always have to specify the fallback value and it is usually the same value through all the block. I suppose it could potentially be solved with monad transformers and `State` monad, and if yes, please tell in the comments how.

## FRP and Running

Finally, let’s implement it! Using event streams from the [FRP Events Library](https://github.com/paf31/purescript-event).

It’s rather simple: we provide the initial model (`init`), we create the actions stream, and on every push of some action, we call the FSM’s `update` function on it, skipping the effects from previous update. And we subscribe to the stream of updates to perform all the effects requested after the update.  Then we provide user with the ability to `push` actions into system.  Which is quite useful for UIs for example, to push some specific action in response to the HTML event handler.

```haskell
run
    :: forall action model
     . FSM action model
    -> model
    -> Effect
            { push :: action -> Effect Unit
            , stop :: Effect Unit
            }
run (FSM updateF) init = do
    { event : actions, push } <- Event.create
    let
        (updates :: Event (model /\ Effect (List action))) =
            Event.fold
                (\action prev -> updateF action $ Tuple.fst prev)
                actions
                (init /\ pure [])
    stop <- Event.subscribe updates
        \(_ /\ eff) -> eff >>= traverse_ pushAction
    pure { push, stop }
```

This has a little sense though, since you have no way to see what models are, so let’s add the ability to specify the subscription to models. The problem with just returning the event stream of models is that if you subscribe to it after the subscription which performs the effects, you get the results of these calls in the model stream as well, which you would probably like to avoid.

```haskell
run
    :: forall action model
     . FSM action model
    -> (model -> Effect Unit)
    -> model
    -> Effect
            { push :: action -> Effect Unit
            , stop :: Effect Unit
            }
run (FSM updateF) subModels init = do
    { event : actions, push : pushAction } <- Event.create
    let
        (updates :: Event (model /\ Effect (List action))) =
            Event.fold
                (\action prev -> updateF action $ Tuple.fst prev)
                actions
                (init /\ pure [])
        (models :: Event model)
            = Tuple.fst <$> updates
    stopModelSubscription <- Event.subscribe models subModels
    stopPerformingEffects <- Event.subscribe updates
        \(_ /\ eff) -> eff >>= traverse_ pushAction
    pure
        { push : pushAction
        , stop : stopModelSubscription <> stopPerformingEffects
        }
```

We can use it to _fold_ some list of actions and get the latest model out of it:

```haskell
fold
    :: forall action model f
     . Foldable f
    => FSM action model
    -> model
    -> f action
    -> Effect model
fold fsm init actionList = do
    lastValRef <- Ref.new init
    { pushAction, stop } <-
        FSM.run fsm (flip Ref.write lastValRef) init
    _ <- traverse_ pushAction actionList
    lastVal <- Ref.read lastValRef
    pure lastVal
```

Running a `CoveredFSM` instance is just calling the `FSM.run` for the underlying instance, like this:

```haskell
run
    :: forall action model
     . CoveredFSM action model
    -> (model -> Effect Unit)
    -> model
    -> Effect
            { push :: action -> Effect Unit
            , stop :: Effect Unit
            }
run (CoveredFSM fsm) = FSM.run fsm
```

## UI, Renderers and VDOM

Now, to the UI part. Finite State Machine only lacks one addition to be able to render model into some view. And this addition is easily represented with a corresponding function:

```haskell
data UI action model view =
    UI (FSM action model) (model -> view)
```

The UI which stores the information about errors is:

```haskell
type CoveredUI error action model view =
    UI action (Covered error model) view
```

Since we hide the `FSM` under the `UI` type constructor, we may avoid using `CoveredFSM` type and provide making functions like these:

```haskell
make
    :: forall action model view
     . (action -> model -> model /\ Effect (List action))
    -> (model -> view)
    -> UI action model view
make updateF viewF =
    UI (FSM.make updateF) viewF


makeCovered
    :: forall error action model view
     . (action
            -> Covered error model
            -> Covered error model /\ Effect (List action))
    -> (Covered error model -> view)
    -> UI error action model view
makeCovered updateF viewF =
    UI (FSM.make updateF # FSM.joinWith (<|>)) viewF


makeCovered'
    :: forall error action model view
     . Semigroup error
    => (action
            -> Covered error model
            -> Covered error model /\ Effect (List action))
    -> (Covered error model -> view)
    -> UI error action model view
makeCovered' updateF viewF =
    UI (FSM.make updateF
            # FSM.joinWith Covered.appendErrors) viewF
```

And, this way running UI is as easy as:

```haskell
run
    :: forall action model view
     . UI action model view
    -> model
    -> Effect
        { next :: Event view
        , push :: action -> Effect Unit
        , stop :: Canceler
        }
run (UI fsm viewF) model = do
    { event : views, push : pushView } <- Event.create
    { push, stop } <-
        FSM.run fsm (pushView <<< viewF) (Covered.carry model)
    pure
        { next : views
        , push
        , stop
        }
```

What user gets is response is the stream of views and we can now feed it to the rendering engine.

Let’s address to `Halogen` VDOM engine which is distributed in a [separate package](https://github.com/purescript-halogen/purescript-halogen-vdom). First, we now definitely render to HTML:

```haskell
type HtmlRenderer error action model =
    CoveredUI error action model (Html action)
```

Another confession I have to make: currently, yes, it’s the `Html` from the `Spork` library. But since in this article we intentionally decline the techniques behind the libraries like `Spork` for the sake of learning, I had to keep it in secret till the end. Also, it is still up to you which output you want to have, _SVG_ or _canvas_ or _text string_ or may be even you will decide to output to terminal using _ASCII_, for all `view`s it works the same!

And we’re just giving the specific examples.

This code is a bit more complicated since `VDOM` and `HTML` API are both not as friendly as ours, but still it works like a charm:

```haskell
embed
    :: forall action model
     . String
    -> HtmlRenderer action model -- renderer
    -> model -- initial model
    -> Effect Unit
embed sel render firstModel = do
    doc <- DOM.window >>= DOM.document
    mbEl <- DOM.querySelector
                (wrap sel)
                (HTMLDocument.toParentNode doc)
    case mbEl of
        Nothing -> throwException
                    (error $ "Element does not exist: " <> sel)
        Just el -> do
            { next, push }
                <- UI.run renderer firstModel
            let
                vdomSpec = V.VDomSpec
                    { document : HTMLDocument.toDocument doc
                    , buildWidget: buildThunk unwrap
                    , buildAttributes: P.buildProp push
                    }
            first_vdom <- EFn.runEffectFn1
                            (V.buildVDom vdomSpec)
                            (unwrap
                                $ UI.view renderer
                                $ Covered.carry firstModel)
            vdom_ref <- Ref.new first_vdom
            void $ DOM.appendChild
                    (Machine.extract first_vdom)
                    (DOMElement.toNode el)
            cancel <- Event.subscribe next $
                \next_view -> do
                    prev_vdom <- Ref.read vdom_ref
                    next_vdom <- EFn.runEffectFn2
                                    Machine.step
                                    prev_vdom
                                    (unwrap next_view)
                    _ <- Ref.write next_vdom vdom_ref
                    pure unit
            pure unit
```

Wait… It turns out the `VDOM` engine uses the Finite State Machines under the hood as well. Just _a bit_ more complicated ones.

## The Stub and the Actual App

We need some actual code to work with the system, let’s do some stubs:

```haskell
data Error = Error

data Action = Action

data Model = Model


init :: Model
init = Model


update
    :: Action
    -> Covered Error Model
    -> Covered Error Model /\ List (Effect Action)
update action covered = covered /\ List.Nil


view
    :: Covered Error Model
    -> Html Action
view _ =
    H.div [] [ H.text "example" ]


myRenderer :: HtmlRenderer Error Action Model
myRenderer =
    Ui.makeCovered update view
```

Finally, your main function can now be as easy as:

```haskell
main :: Effect Unit
main =
    VDom.embed "#app" myRenderer init
```

That’s it, folks!

## Aftermath

### Aftermath One

What we defined as `UI` is actually containing both application logic (the `FSM` stored inside) and rendering (`model -> view` function), so you could want to separate these functions or just rename `UI` to `App` and abstract your application by `view`:

```haskell
data App action model view =
    App (FSM action model) (model -> view)

data App' error action model view  =
    App'
        (FSM action (Covered error model))
        (Covered error model -> view)

type MyApp view = App' Action Model view


myApp :: App Action Model (Html Action)
myApp = Ui.makeCovered update view
```

It is the same things as `HtmlRenderer` defined above, so embedding is no different:

```haskell
main :: Effect Unit
main =
    VDom.embed "#app" myApp init
```

But now you may reuse the same logic for different views.

### Aftermath Two

Another thing. This would be useful to `map` over the `FSM` types to convert, for example, `FSM action (Either error model)` to `FSM action (Covered error model)` with just one call, but if you try to implement `Functor` instance for it, you’ll find that to do it we also need a function to convert `Covered` to `Either` back, which breaks the `Functor` logic, of course. But it looks like there’s `Invariant`for that!

```haskell
imapModel
    :: forall action modelA modelB
     . (modelA -> modelB)
    -> (modelB -> modelA)
    -> FSM action modelA
    -> FSM action modelB
imapModel mapAToB mapBToA (Fsm updateF) =
    FSM \action modelB ->
        Bifunctor.bimap mapAToB identity
            $ updateF action
            $ mapBToA modelB


instance invariantFSM :: Invariant (FSM action) where
    imap = imapModel
```

…Unfortunately, no, `imap` is not enough, because you can not create `Covered` out of thin air if there’s `Left error` value in `Either` part—you need some value to put in `Covered`. You may use `imap` for any cases where models are easily converted both one to another and back without the loss of data.

### Aftermath Three

Remember I noticed that it’s better to use `List (Effect action)` rather than `Effect (List action)`? It indeed is, and it requires just one change in the code of the `run` function. To replace:

```haskell
    stopPerformingEffects <- Event.subscribe updates
        \(_ /\ eff) -> eff >>= traverse_ pushAction
```

with

```haskell
    stopPerformingEffects <- Event.subscribe updates
        \(_ /\ effs) -> traverse_ ((=<<) pushAction) effs
```

Done. The example is written using `List (Effect Action)`, by the way.

### Aftermath Four

And the last. `Covered` type has the `Bind` instance such as (where `recover` extracts the value from the `Covered` type):

```haskell
instance coveredBind
    :: Semigroup e => Bind (Covered e) where
    bind covered k = appendErrors covered $ k $ recover covered
```

You’ve seen `appendErrors` above. So now you know, that you may use `>>=` anywhere to join errors between two `Covered` values in any place.

### Aftermath Five

One project that inspired me for using PureScript with FRP is [Flare](https://david-peter.de/articles/flare/). The way it uses Functor and Applicative instances to adapt the values inside of the components is just awesome and they are all just one-liners. So the future plan is to find a way to do similar things with FSMs.

### And Everything Else…

Don’t forget to take a look at [the example](https://dev.to/shamansir/purescript-ui-driven-by-finite-state-machines-and-event-streams-part-ii-the-example-3m77) which has the code with the effects, and passing actions from the `UI` and everything you would question about during reading this article. Hope you enjoyed it.

Also, here is the [example source code](https://github.com/shamansir/purescript-fsm).

On the other hand, the article could contain errors and misleading information, not intentionally, of course. If you notice such case, please inform the author and the readers as soon as possible by leaving a friendly, yet correcting, comment.

If you see the ways to improve the approach, please also do comment. Even comment if you have ideas on how to do things worse.

[^1]:	There is some controversy on the effectiveness of the approach, but let’s decide the author (for sure) and the reader (hope so) still think the approach is just awesome, if you use it right.
