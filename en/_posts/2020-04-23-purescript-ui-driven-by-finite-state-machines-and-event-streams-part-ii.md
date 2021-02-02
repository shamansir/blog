---
layout: post.html
title: "PureScript: UI driven by Finite State Machines and Event Streams, Part II: The Example"
datetime: 07 Apr 2020 14:07
tags: [ purescript, functional-programming ]
excerpt: Building UIs as state machines is not a new approach, and may appear common to a reader by some other names. Still, in PureScript, with it's freedom to choose any approach you like, it may seem not to come to head as a first thought, or even second one. Usually one may just use some framework. This post is about what could be behind your framework and for those who want to consider different ways to write UI by hand in PureScript. As the title says, plus accumulating errors and recovering to the latest successful state.
---


Just to recall, [in the first part](https://dev.to/shamansir/purescript-ui-driven-by-finite-state-machines-and-event-streams-994) we are discussing using the Finite State Machines for UI with the possibility to collect errors, the ability to rollback to the last successful state, and created using Event Streams, and this is the second part with the actual practical example.

To give you a nice example other than a shopping cart or ATM, let’s recall the game of Animal Crossing: New Horizons. If you haven’t played it, you most probably heard about it nowadays, but it’s not important since I will describe the scheme anyway and there should be no huge spoilers.

First, the complete source code. It’s here: [https://github.com/shamansir/purescript-ffm](https://github.com/shamansir/purescript-fsm). To run it, an least four commands are needed to be executed (the project is working on `spago` + `parcel` ):

```haskell
npm install -g purescript spago
npm install
npm run build
npm run dev
```

You should be able now to go to http://localhost:1234 and observe some weird interface there, which we cover below, but first let’s explain the basic logic behind it.

![The Interface](https://dev-to-uploads.s3.amazonaws.com/i/gwmdiwty8lvc6xi4o462.png)

It also has tests made with awesome `purescript-spec`, you can easily run them using:

```haskell
npm run test
```

![Alt Text](https://dev-to-uploads.s3.amazonaws.com/i/m0z9b1q35lm48c9c6dx8.png)

There is a museum and it has (yet discovered by me to the moment) three stages of development:

### The Plot

First, you are catching bugs and fishing and deliver these specimens to the bear (bear with me, I can promise we are all sane!), who is very serious about business and who collects your species until the amount reaches five.

They all should be unique though, and that requirement goes through the whole system. Everything that already exists in the museum or extends the amount of one, will be returned back to you.

Only after that, you are introduced to Blathers, the owl that lives in a tent and has some botanical and archeological skills. Now, in addition to aggregating bugs and fish, you also can dig up the fossils with the shovel, which are then “unpacked” by Blathers to some specific part of an outdated animal skeleton and returned to you, only after that you know what was inside of that fossil.

And so now you deliver the bugs and fossils to the tent, and the owl has one _side effect_ of telling you the very detailed, perfectly scientific, story about every new creature you’ve found. You always have an option to decline and nobody will judge you (_won’t they, actually? there are rumours that the animals were not that polite in the previous games of series…_).

Now, when you reach the 15 of species (unique unpacked fossils also count as one), you can select the place for the large fancy museum and have it built it on the next day. It has three floors and all your bugs and fish and skeletons (not the ones from the closet) are located in here.

And now you also get a nice option to deliver several unique things at once and politely omit the _side effect_of hearing the story. Sometimes it looks like Blathers is actually also bored with telling, but the curiosity, or may be ethic rules, keeps me asking him to tell and tell them again and again.

### The Interface

In the interface, there are some buttons at the top, and they are only usable by player, which means _you_. You are the God here and the button of the God is the one that just produces errors, for sure. Also you can dig, catch bugs and go fishing, but ensure to press these buttons a lot of times, because the chance that you get something in response is 40%. We do use random numbers here!

Aside from that, you can see all the species you have (none for the moment), grouped by bugs/fish/skeletons/fossils and then by quantity and kind, and much more details about the _future_ museum.

You can deliver the items you have to the museum, but the museum will take only the unique ones, and just one item of such (even though you’re God and they should’ve store pairs of them, ignorant… animals!). Everything else gets back to you.

But the situation with _fossils_ is different! You don’t know what’s inside of them. You can not deliver them to the museum at the first stage where Tom Nook rules the party, since he is unable to unwrap that fossils too. Only Blathers has required education, so you have to upgrade to the tent before delivering them. Also, after that he only unwraps them and returns them back as the skeleton parts, which you may then try to deliver the usual way.

Upgrading: When you have delivered enough of unique species to upgrade (5 for the tent, 10 for the building), the museum will close until you will find the location for the tent or the building. In the game, you would have to wait for a day after that, but we are not that realistic here, so when you find the location (by pressing the corresponding button and so choosing it randomly) the museum just opens back again.

I won’t inspect the source line by line, but rather will just discuss with you the most important parts.

### The Structure of Code

The most interesting for you should be the `Example.purs` file, it has all the logic discussed above. Secondly, the `Ui.purs`, which specifies the rendering engine in just a few lines. And the last may be `VDom.purs`, which reuses the `Halogen`’s `VDom` engine to actually render stuff and run the User Interface.
And, of course, `Fsm/Fsm.purs`, but we have discussed it in the details through all the first part, so you already know everything about it, don’t bother looking!

### The FSM

Okay, just a quick look. It is different from the article in the sense that it collects effects in the list rather than produces a singe effect with a list of actions as the result:

```haskell
data Fsm action model =
    Fsm (action -> model -> model /\ List (Effect action))
```

Everything else is the same and takes just a dozen of lines. Well, ten dozens, but it’s just because we have no economy for lines of code in functional languages, it is the infinite resource here!

### The Rendering

We just redefine the original `Fsm` with model being the `Covered`type and use it for the `Ui`, that’s it:

```haskell
type CoveredFsm error action model =
	Fsm action (Covered error model)


data Ui error action model view =
    Ui
		(CoveredFsm error action model)
		(Covered error model -> view)
```

Notice the `make` and `make'` functions, they are different in the way of joining or not joining errors, as discussed in the original article:

```haskell
make
    :: forall error action model view
     . (action
            -> Covered error model
            -> Covered error model /\ List (Effect action))
    -> (Covered error model -> view)
    -> Ui error action model view
make updateF viewF =
    Ui (Fsm.make updateF # Fsm.joinWith (<|>)) viewF


make'
    :: forall error action model view
     . Semigroup error
    => (action
            -> Covered error model
            -> Covered error model /\ List (Effect action))
    -> (Covered error model -> view)
    -> Ui error action model view
make' updateF viewF =
    Ui (Fsm.make updateF
            # Fsm.joinWith Covered.appendErrors) viewF
```

### Implementation

We have `Action` and `Model` and `Error` here and also he have an `App`:

```haskell
data Action
	= ...

data Model
	= ...

data Error
	= ...

type App =
    Ui Error Action Model (Html Action)
```

We create it using `Ui.make`:

```haskell
app :: App
app =
    Ui.make' update' view'
```

Notice the quotes. If you change `make'` to `make`, then it no more requires `Semigroup` for errors, so they are aggregated no more, just the latest one is going through all the engine. You’ll notice it when you run the example and do something erroneous or just press the almighty “Produce Error” button. Just a subtle change leads to such serious consequences!

`update'` is different from `update` only by the fact it unwraps the `Covered` model since in the logic we don’t care, were there errors before or not:

```haskell
update'
	:: Action
    -> Covered Error Model
    -> Covered Error Model /\ List (Effect Action)
update' action covered =
    update action $ Covered.recover covered

update
	:: Action
	-> Model
	-> Covered Error Model /\ List (Effect Action)
update ...
```

`view'` with the quote just also renders the error(-s) when it (they) happened before:

```haskell
view' :: Covered Error Model -> Html Action
view' covered =
    case covered of
        Carried model -> view model
        Recovered error model ->
            H.div
                [ ]
                [ view model
                , H.text $ "Latest errors: " <> show error
                ]


view :: Model -> Html Action
view ...
```

To run it, we use `Ui.run` in the `VDom.purs`.

Regarding `Semigroup` and `Error`s, we have a special constructor for the errors to collect them:

```haskell
data Error
	= ...
    | SeveralErrors (List Error)
```

And the `Semigroup` implementation:

```haskell
instance semigroupError :: Semigroup Error where
    append (SeveralErrors listA) (SeveralErrors listB)
		= SeveralErrors $ listA <> listB
    append singleError (SeveralErrors list)
		= SeveralErrors $ singleError : list
    append (SeveralErrors list) singleError
		= SeveralErrors $ list <> pure singleError
    append singleErrorA singleErrorB
		= SeveralErrors $ pure singleErrorA <> pure singleErrorB
```

You may just use `List Error` when you specify the `App` and don’t care about `Semigroup` instance at all, but I wanted to demonstrate how easy it is to change from the multi-error mode to the single-error mode using one press of a key and here you need a bit more pressing:

```haskell
type App =
    Ui (List Error) Action Model (Html Action)
```

### Actions, Producing

From now we discuss the `update` function code, the one without a quote.

There are no cases in this example where several actions would be produced in response to another action, may be it needs improvement.

If there would be one, it would look like this:

```haskell
pure model /\ pure Dig : pure Catch : pure GoFishing : Nil
```

For now, it is usually just one:

```purescript
pure model /\ pure Deliver : Nil
...
pure model /\ pure DeliverFossils : Nil
```

### Effects, Producing

In this implementation each effect is bound to an action, for example to decide if you catch something at all and if you do, what kind of bug you’ve got, we use random numbers and random weight distribution, which is surely an effect:

```haskell
playerUpdate Catch =
    pure model
    /\ do
        n1 <- Random.random
        n2 <- Random.random
        pure $ Player
             $ decide
                (GetBug $ decide' bugsChoice Tarantula n2)
                GetNoBug 0.4 n1
        : Nil
```

With the first number `n1` we decide by 40% possibility if there is a bug, and then we use the second number `n2` to decide which kind of bug exactly, using this weight definition:

```haskell
bugsChoice
    = (Butterfly /\ 0.40)
    : (Spider /\ 0.30)
    : (Ladybug /\ 0.15)
    : (Caterpillar /\ 0.10)
    : (Tarantula /\ 0.05)
    : Nil
```

So, we either return the action `GetNoBug` or  the action`GetBug <SomeBug>` in response.

To find a location for the museum, we also use random numbers:

```haskell
playerUpdate FindMuseumSpot =
    pure model
    /\ (Player <<< LocateMuseumSpot <<< Location
           <$> ((/\) <$> Random.random <*> Random.random)
       ) : Nil
```

If you are eager to play with the code, take the challenge of implementing the effect of telling the scientific story by Blathers, it should be as easy as these examples.

### Errors, Producing

For example, you can’t locate the spot for the museum if it’s open, it only can be closed, so we produce an error if we’ve met that case. Previously I’ve disabled the buttons in the interface if such conditions would happen, but lately I decided that it is better demonstrates the error system if they are always enabled.

To produce an error (and it can be accumulated automatically!), it is just as easy as `cover` the previous model in the `Covered` instance together with that error.

```haskell
playerUpdate (LocateMuseumSpot location)
    | not model.museum.open = ...
    | otherwise =
        (NoLocatingAllowed # Covered.cover model) /\ Nil
```

Since we have `SeveralErrors` there, it is also possible to produce lists of them. Which would be merged automatically with the previous ones thanks to the `UI.make'` implementation and `Semigroup` instance.

Some more examples:

```haskell
playerUpdate Deliver
	| canDeliver model.museum =
		pure ... /\ pure ConsiderSpecies ... : Nil
	| otherwise =
        (NoSpeciesDeliveryAllowed # Covered.cover model) /\ Nil

playerUpdate DeliverFossils
	| canDeliverFossils model.museum =
		pure ... /\ pure ConsiderFossils ... : Nil
	| otherwise =
        (NoFossilsDeliveryAllowed # Covered.cover model) /\ Nil
```

Haven’t I wrote in the first part that I don’t use separate constructors for different errors? I lied!

### Finalé

Now that is really it. I hope this pair of articles will find it useful for somebody.

Again, please feel free to comment and everything else is appreciated.

I am [`shaman_sir`](https://twitter.com/shaman_sir) in Twitter and usually I post either functional programming things or the things about generative graphics (sometimes my own), and I can promise that more to come, especially where these both topics meet each other. Stay tuned.

Also, my personal blog which demonstrates the weird ways I took to reach the PureScript enlightenment, and where I should add these too articles a bit later:
[https://shamansir.github.io/blog/](https://shamansir.github.io/blog/).

Thank you!
