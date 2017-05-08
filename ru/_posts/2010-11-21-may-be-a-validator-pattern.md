---
layout: post.html
title: UI-Паттерн Validator, может так?
datetime: 23 Nov 2010 00:03
tags: [ java ]
---

Достаточно часто в пользовательском интерфейсе нужно отображать, подходящие данные ввёл пользователь или нет. В зависимости от ситуации подсвечивать зелёным или красным поля или показывать около них подсказки. Существует много плагинов/библиотек для множества фреймворков, но какого-либо особого, в меру простого, стандарта, похоже нет. То есть, может стоит изобрести ещё один велосипед, но попробовать сделать его поудобнее.

Есть [JSR-303](http://people.redhat.com/~ebernard/validation/) ([о нём на хабре](http://habrahabr.ru/blogs/java/68318/), [и ещё немного на английском](http://java.dzone.com/articles/bean-validation-and-jsr-303)), он предназначен для валидации java-бинов с помощью аннотаций, похожа на него (и одновременно на мою версию) и библиотека [gwt-validation](http://code.google.com/p/gwt-validation/) для GWT - эти вещи попроще чем обычно. Предлагаемый мной вариант ориентирован больше на UI-компоненты, чем данные с которыми они работают, на разных страницах может потребоваться валидация разной строгости и разное оформление (+`i18n`), да и управлять ограничениями формы по-моему удобнее в самой форме.

Кстати, тут наверное множество UI-профессионалов, поэтому я только за, чтобы отмечаться в комментариях.

Постараюсь описать максимально независимо от языка программирования, но примеры придётся приводить на Java :).

### Концепция

* Один метод `validate()` для композитного компонента (формы) который возвращает первый тип ограничения, не прошедший валидацию или `null`, если валидация пройдена. Этот метод может использоваться для проверок при нажатии на кнопки типа "Сохранить" или "Отправить", когда важен только первый не прошедший тест.
* Этот же метод `validate()` можно вызвать для любого UI-компонента в форме и он изменит своё визуальное состояние в соответствии с введённым в него значением. А также при вызове этого метода у формы в целом - каждый компонент на ней также обновит своё состояние.
* Валидирующий код может иметь возможность бросить исключение о валидации, но не обязан.
* В общем случае все компоненты реагируют на корректные/некорректные значения одинаково.
* Не более трёх основных классов/интерфейсов.

### Диаграмма

Сама диаграмма охватывает все описанные в статье классы, поэтому выглядит довольно (мягко говоря) эпично, но к самому паттерну, как я считаю, следует относить только верхний левый пакет `[Core]`.

[![Диаграмма рассматриваемого паттерна]({{ get_figure(slug, 'diagram-thumb.png') }})]({{ get_figure(slug, 'diagram.png') }})

----

### Основные классы

#### Ограничение

Отправной точкой будет самый весомый класс - базовый `Constraint` - какое-либо ограничение. В моём случае тип ограничения задан простым `enum`-ом, поскольку возможные виды ограничений обычно вполне исчислимы. Вместо `enum`-а может быть и просто какое-либо абстрактное уникальное число, которое передаётся из наследников `ValidationConstraint`, тогда о типе ограничения будут знать только они и `i18n`-модуль.

``` java

public class ValidationConstraint {

	public enum ConstraintType { INVALID_FORMAT, // Значение в поле не соответствует регулярному выражению
                                 ILLEGAL_CHARACTERS, // Частный случай первого, в поле введены недопустимые символы
                                 INVALID_VALUE, // Частный случай первого, вместо числа введена строка или подобные ограничения
                                 REQUIRED_VALUE, // Поле требуется к заполнению
                                 BOTH_OR_NONE_REQUIRED, // Требуется указать оба поля или ни одно из них
                                 MUST_BE_GREATER_THAN, // Значение в поле должно быть больше чем...
                                 MORE_ITEMS_THAN_ALLOWED, // Выбрано больше элементов, чем требуется
                                 . . .
                               };

    private final ConstraintType type;
    private final String subject;
    private final String expectedValue;
    private final String failedValue;

    private static final ValidationMessages messages = /* Получить локализованные сообщения */;

    public ValidationConstraint(ConstraintType type, String subject, String expectedValue, String failedValue) {
        this.type = type;
        this.subject = subject;
        this.expectedValue = expectedValue;
        this.failedValue = failedValue;
    }

    public ConstraintType getType() { return type; }
    public String getSubject() { return subject; }
    public String getExpectedValue() { return expectedValue; }
    public String getFailedValue() { return failedValue; }

    public String getLocalizedDescription() {
        switch (getType()) {
            case INVALID_CHARACTERS: return messages.invalidCharacters(subject, expectedValue, failedValue);
            case INVALID_FORMAT: return messages.invalidFormat(subject, expectedValue, failedValue);
            case INVALID_VALUE: return messages.invalidValue(subject, expectedValue, failedValue);
            case REQUIRED_VALUE: return messages.requiredValue(subject);
            case MORE_ITEMS_THAN_ALLOWED: return messages.moreThanAllowed(subject, expectedValue, failedValue);
            case BOTH_OR_NONE_REQUIRED: return messages.bothOrNoneRequired(subject);
            case MUST_BE_GREATER_THAN: return messages.mustBeGreaterThan(subject, expectedValue, failedValue);
            . . .
            default: return messages.unknownConstraint();
        }
    };

}

```

#### Объект, который можно проверить

Любой объект, который может быть проверен на соответствие ограничениям, должен имплементировать интерфейс `IValidatable`. Метод `validate()` можно вызвать, если нужно получить \[первый\] свалившийся `Constraint` или нужно обновить состояние компонента (когда не важно возвращаемое значение). Метод `isValid` можно вызвать если требуется просто проверить, прошло ограничения (ограничения) или нет - в подавляющем большинстве случаев `isValid()` равноценно `(validate() == null)`.

``` java

public interface IValidatable {

    public ValidationConstraint validate();
    public boolean isValid() throws ValidationException;

}

```

Также `isValid()` может бросать исключение, содержащее тип ограничения, которое не прошло:

``` java

public class ValidationException extends Exception {

    private final ValidationConstraint constraint;

    public ValidationException(ValidationConstraint constraint) {
        super(constraint.getFailedValue());
        this.constraint = constraint;
    }

    @Override
    public String getLocalizedMessage() {
        return constraint.getLocalizedDescription()/* + " (" + constraint.getType() + ")"*/;
    }

}

```

#### Объект, содержащий несколько ограничений

Таким объектом может стать, например, форма или страница с полями для заполнения или какой-либо бин. Этот объект должен имплементировать интерфейс `HasConstraints`. Метод `initContraints()` можно вызывать в конструкторе имплементирующего класса или в каком-либо другом методе, выполняющемся один раз перед использованием объекта. `addConstraint(...)` добавляет новое ограничение, за которым следит объект. Также он наследует метод `validate()`, который перебирает все ограничения и возвращает первое упавшее. В этот объект можно встроить возможность удаления ограничений, тогда он будет действовать примерно как `Observer`.

``` java

public interface HasConstraints extends IValidatable {

    public void initConstraints();
    public void addConstraint(IValidatable validatable);

}

```

#### Как использовать снаружи

То, что доступно конечному разработчику в результате - любые формы и страницы, которые могут переопределить метод `initConstraints` и вызвать поочерёдно для каждого ограничения на какое-либо поле метод `addConstraint(...)`. Метод `addConstraint(...)` принимает параметром любой объект, который умеет себя валидировать (имплементирует `IValidatable`) или, для ограничений, экзепляр из уже готового набора ограничений (которые, в свою очередь, тоже имплементируют тот самый `IValidatable`). Перед сохранением/отправкой формы разработчик может вызывать у этих страниц/форм метод `validate()` или `isValid()`, чтобы узнать что именно упало или перехватить/передать исключение валидации. Все ограничения автоматически проверяются при изменении значений в этих полях.

Ниже я рассмотрю дополнения и примеры, которые никоим образом не изменяют это утверждение.

----

### Дополнения

#### Обновляющий состояние объект

Если какой-либо объект содержит значение, то он может сам проверять своё состояние на основе ограничений. Такой объект может имплементировать интерфейс `Validator`. Методы `whenValueInvalid(...)` и `whenValueValid(...)` могут вызываться напрямую при проверке из имплементируемого `validate()`, тогда вызов `validate()` всегда будет обновлять состояние объекта.

``` java

public interface Validator<V> extends IValidatable {

    public V getValue();

    public void whenValueInvalid(V value, ValidationConstraint constraint);
    public void whenValueValid(V value);

}

```

### Делегирование объекта, обновляющего состояние

Чаще удобнее делегировать такой объект, потому что он может быть уже готовым компонентом, цепочку наследования которого нельзя изменять. Будем называть делегируемый объект целью - `Target`. Ожидаемое поведение здесь такое же как и в интерфейсе `Validator`.

``` java

public interface TargetValidator<V, T> extends IValidatable {

    public V getValue();
    public T getTarget();

    public void whenValueInvalid(T target, V value, ValidationConstraint constraint);
    public void whenValueValid(T target, V value);

}

```

Впрочем, могут понадобиться несколько слушателей, реагирующих на изменение значения. Поэтому я создал интерфейс `ValueChangeReactor` и изменил `TargetValidator`, чтобы он расширял этот интерфейс (хотя это необязательно). В примерах я буду придерживаться этого варианта.

``` java

public interface ValueChangeReactor<V, T> {

    public void whenValueInvalid(T target, V value, ValidationConstraint constraint);
    public void whenValueValid(T target, V value);

}

public interface TargetValidator<V, T> extends IValidatable, ValueChangeReactor<V, T> {

    public V getValue();
    public T getTarget();

}

```

Теперь можно создавать объекты, которые содержат слушателей на изменения значений. Допустим, один из слушателей добавляет к объекту CSS-класс, другой - подсказку.

``` java

public interface HasValueReactors<V, T> {

    public void addReactor(ValueChangeReactor<V, T> reactor);

}

```

Без примеров статья была бы неполной...

----

### Примеры

#### Базовая "коробка проверяемых объектов"

Вот класс, от которого может наследоваться любой объект (например, та самая форма или страница), который содержит в себе другие проверяемые объекты (в том числе ограничения) и собственно проверяет их при вызове `validate()`. Дочерние классы должны иметь метод `initConstraints()`, который будет добавлять все неоходимые для проверки объекты.

``` java

public abstract class ValidationSupport implements HasConstraints {

    private final Set<IValidatable> validatables = new LinkedHashSet<IValidatable>();

    @Override
    public ValidationConstraint validate() {
        for (IValidatable validatable: validatables) {
            final ValidationConstraint constraint = validatable.validate();
            if (constraint != null) return constraint;
        }
        return null;
    };

    @Override
    public void addConstraint(IValidatable validatable) {
        validatables.add(validatable);
    }

    public boolean isValid() {
        return (validate() == null);
    }

}

```

Однако, если нельзя нарушать цепочку наследования, удобнее делегировать объект этого класса, переопределив `initConstraints` на вызов `initContraints` у оборачивающего объекта.

> Обратите внимание на то, что у наследуемого или делегирующего объекта `initConstraints` нужно вызывать вручную, например после подготовки и создания всех компонентов формы. В большинстве случаев, однако, подойдёт и просто вызов в конструкторе.

#### Базовое ограничение

От этого класса могут наследоваться все конкретные ограничения. Он позволяет передать валидируемый компонент (`target`), тип ограничения (`constraintType`), "название" компонента (`subject`) и ожидаемое значение (`expectation`). Собственно, он и выполняет описанные выше ожидания от `TargetValidator`. Метод `passes()` наследника должен проверять, соответствует ли текущее значение типу ограничения.

``` java

public abstract class BaseValidator<V, T> implements TargetValidator<V, T>, HasValueReactors<V, T> {

    private final T target;
    private final String subject;
    private final String expectation;
    private final ConstraintType constraintType;
    private final Set<ValueChangeReactor<V, T>> reactors = new LinkedHashSet<ValueChangeReactor<V, T>>();

    public BaseValidator(T target, ConstraintType constraintType, String subject, String expectation) {
        this.target = target;
        this.subject = subject;
        this.expectation = expectation;
        this.constraintType = constraintType;
    }

    protected BaseValidator(T target, ConstraintType constraintType, String subject) {
        this(target, constraintType, subject, null);
    }

    protected abstract boolean passes(V value);

    @Override
    public T getTarget() { return target; }

    @Override
    public final ValidationConstraint validate() {
        final V value = getValue();
        final boolean passes = passes(value);
        ValidationConstraint constraint = null;
        if (passes) {
            whenValueValid(target, value);
        } else {
            constraint = new ValidationConstraint(constraintType, subject, expectation, (value != null) ? value.toString() : "");
            whenValueInvalid(target, value, constraint);
        }
        return constraint;
    }

    public boolean isValid() {
        return (validate() == null);
    }

    /* Либо:
    public boolean isValid() throws ValidationException {
        ValidationConstraint constraint = validate();
        if (constraint != null) throw new ValidationException(constraint);
        return (constraint == null);
    } */

    @Override
    public void whenValueInvalid(T target, V value, ValidationConstraint constraint) {
        for (ValueChangeReactor<V, T> reactor: reactors) {
            reactor.whenValueInvalid(target, value, constraint);
        }
    }

    @Override
    public void whenValueValid(T target, V value) {
        for (ValueChangeReactor<V, T> reactor: reactors) {
            reactor.whenValueValid(target, value);
        }
    }

    @Override
    public void addReactor(ValueChangeReactor<V, T> reactor) {
        reactors.add(reactor);
    }

}

```

----

### Практика

#### Практика: Валидирование UI-компонентов

Допустим, в нашем UI-фреймворке у нас чётко выделяются компоненты, которые имеют какое-то значение и имеют хэндлеры, которые вызываются при его изменении - то есть имплементируют некий интерфейс `HasValue` (см., например, [HasValue в GWT](http://google-web-toolkit.googlecode.com/svn/javadoc/2.0/com/google/gwt/user/client/ui/HasValue.html)). Можно создать валидатор, который будет автоматически следить за изменениями значения таких объектов (событие изменения вызывается, к примеру, при потере фокуса у текстового поля) и сразу же валидировать значение (вызывая `validate()`).

``` java

public abstract class ValueContainerValidator<V, T extends HasValue<V>> extends BaseValidator<V, T> {

    public ValueContainerValidator(T target, ConstraintType constraintType, String fieldName, String expectation) {
        super(target, constraintType, fieldName, expectation);

        addValidationHandlers(target);
    }

    public ValueContainerValidator(T target, ConstraintType constraintType, String fieldName) {
        this(target, constraintType, fieldName, "");
    }

    protected void addValidationHandlers(T target) {

        target.addValueChangeHandler(new ValueChangeHandler<V>() {
            @Override public void onValueChange(ValueChangeEvent<V> event) {
                validate();
            }
        });

        /* if (target instanceof HasKeyUpHandlers) {
            ((HasKeyUpHandlers)target).addKeyUpHandler(new KeyUpHandler() {
                @Override
                public void onKeyUp(KeyUpEvent event) {
                    validate();
                }
            });
        } */

    }

    @Override
    public V getValue() {
        return getTarget().getValue();
    }

}

```

В комментарии показано, что вы можете проверить и другие интерфейсы объекта и, допустим обновлять состояние не только при потере фокуса, но и при нажатии клавиши и т.п.

И наконец, вот несколько часто используемых ограничений:

``` java

public class RegexConstraint<T extends HasValue<String>> extends ValueContainerValidator<String, T> {

    private final String regex;

    public RegexConstraint(T target, String fieldName, String regex, String regexDescription) {
        super(target, ConstraintType.INVALID_FORMAT, fieldName, regexDescription);
        this.regex = regex;
    }

    @Override
    protected boolean passes(String value) {
        return value.isEmpty() || value.matches(regex);
    }

}

public class RequiredFieldConstraint<T extends HasValue<String>> extends ValueContainerValidator<String, T> {

    public RequiredFieldConstraint(T target, String fieldName) {
        super(target, ConstraintType.REQUIRED_VALUE, fieldName);
    }

    @Override
    protected boolean passes(String value) {
        return (value != null) && !value.isEmpty();
    }

}

public class MinimumLengthConstraint<T extends HasValue<String>> extends ValueContainerValidator<String, T> {

    private final int minLength;

    public MinimumLengthConstraint(T target, String fieldName, int minLength) {
        super(target, ConstraintType.LESS_ITEMS_THAN_REQUIRED, fieldName, String.valueOf(minLength));
        this.minLength = minLength;
    }

    @Override
    protected boolean passes(String value) {
        return value.isEmpty() || (value.length() >= minLength);
    }

}

```

Иногда требуется проверить несколько полей в совокупности. Например, для двух полей требуется заполнить либо оба, либо ни одного. Вот пример базового класса для ограничений на два поля:

``` java

public abstract class TwoTargetsConstraint<T extends HasValue<String>> extends ValueContainerValidator<String, T> {

    private final T targetTwo;

    public TwoTargetsConstraint(T targetOne, T targetTwo, ConstraintType constraintType, String fieldName, String expectation) {
        super(targetOne, constraintType, fieldName, expectation);
        this.targetTwo = targetTwo;

        addValidationHandlers(targetTwo);
    }

    public TwoTargetsConstraint(T targetOne, T targetTwo, ConstraintType constraintType, String fieldName) {
        this(targetOne, targetTwo, constraintType, fieldName, "");
    }

    @Override
    public void whenValueInvalid(T target, String value, ValidationConstraint constraint) {
        super.whenValueInvalid(target, value, constraint);
        super.whenValueInvalid(targetTwo, value, constraint);
    }

    @Override
    public void whenValueValid(T target, String value) {
        super.whenValueValid(target, value);
        super.whenValueValid(targetTwo, value);
    }

    @Override
    protected final boolean passes(String value) {
        return passes(value, targetTwo.getValue());
    }

    protected abstract boolean passes(String valueOne, String valueTwo);

}

```

А вот реализация, которая собственно и удостоверяется, что заполнено либо оба поля, либо ни одного:

``` java

public class BothOrNoneRequiredConstraint<T extends HasValue<String>> extends TwoTargetsConstraint<T> {

    public BothOrNoneRequiredConstraint(T targetOne, T targetTwo, String fieldName) {
        super(targetOne, targetTwo, ConstraintType.BOTH_OR_NONE_REQUIRED, fieldName);
    }

    @Override
    protected boolean passes(String valueOne, String valueTwo) {
        return (valueOne.isEmpty() && valueTwo.isEmpty()) ||
               (!valueOne.isEmpty() && !valueTwo.isEmpty());
    }

}

```

В GWT основная часть компонентов наследуется от класса [`UIObject`](http://google-web-toolkit.googlecode.com/svn/javadoc/1.6/com/google/gwt/user/client/ui/UIObject.html), для такого элемента можно добавлять и убирать CSS-стили. Учитывая это можно сделать `StylingReactor`, который при изменении значения добавляет нужный CSS-стиль к объекту:

``` java

public class StylingReactor<V, T extends UIObject> implements ValueChangeReactor<V, T> {

    public StylingReactor() { }

    @Override
    public void whenValueInvalid(T target, V value, ValidationConstraint constraint) {
        target.addStyleName("b-invalid-value");
    }

    @Override
    public void whenValueValid(T target, V value) {
        target.removeStyleName("b-invalid-value");
    }

}

```

Формы, панели и страницы наследуются в GWT от класса [`Composite`](http://google-web-toolkit.googlecode.com/svn/javadoc/2.0/com/google/gwt/user/client/ui/Composite.html). Сделаем базовый `CompositeWithConstraints`, от которого смогут наследоваться такие формы и страницы. По сути он просто делегирует `ValidationSupport`, но кроме этого автоматически добавляет всем внутренним ограничениям, которые вешаются на `UIObject`-компоненты `StylingReactor` (при жуткой необходимости его можно переиспользовать).

``` java

public abstract class CompositeWithConstraints extends Composite implements HasConstraints {

    private final ValidationSupport validationSupport = new ValidationSupport() {

        public void initConstraints() {
            CompositeWithConstraints.this.initConstraints();
        };

    };

    protected CompositeWithConstraints() {

    }

    @Override
    public void addConstraint(IValidatable validatable) {
        validationSupport.addConstraint(validatable);
    }

    public <V, T extends UIObject> void addConstraint(BaseValidator<V, T> validator) {
        validator.addReactor(new StylingReactor<V, T>());
        validationSupport.addConstraint(validator);
    }

    @Override
    public boolean isValid() throws ValidationException {
        return validationSupport.isValid();
    }

    @Override
    public ValidationConstraint validate() {
        return validationSupport.validate();
    }

}

```

> Ещё раз обратите внимание на то, что у наследуемого или делегирующего объекта `initConstraints` нужно вызывать вручную, например после подготовки и создания всех компонентов формы. В большинстве случаев, однако, подойдёт и просто вызов в конструкторе.

#### Пример использования

Допустим `FormWithValidation` наследуется от класса `CompositeWithConstraints`, а `TextBox`, `TextArea` имплементируют интерфейс `HasValue` (так и есть в штатных компонентах GWT):

``` java

public class ProfileEditForm extends FormWithValidation implements View {

    . . .

    @Override
    public void initConstraints() {

        addConstraint(new RequiredFieldConstraint<TextBox>(nameField, "Name"));
        addConstraint(new RequiredFieldConstraint<TextArea>(aboutMe, "AboutMe"));
        addConstraint(new MinimumLengthConstraint<TextArea>(aboutMe, "AboutMe", ProfileBean.MIN_ABOUT_LENGTH));
        addConstraint(new RegexConstraint<TextBox>(academyStartField, "Academy start", StringUtils.DATE_REGEX, "NN-NN-NNNN"));
        addConstraint(new RegexConstraint<TextBox>(academyFinishField, "Academy finish", StringUtils.DATE_REGEX, "NN-NN-NNNN"));
        addConstraint(new BothOrNoneRequiredConstraint<TextBox>(academyStartField, academyFinishField, "Academy"));
        addConstraint(new FirstLessThanSecondConstraint<TextBox>(academyStartField, academyFinishField, "Academy"));

    }

    public HasClickHandlers getSavingButton() { ... }

    . . .

}

```

Теперь эти поля автоматически валидируются при изменении их значений. Для того чтобы проверить соответствие ограничениям перед сохранением формы, достаточно вызвать `validate`:

``` java

public class ProfileEditPresenter implements Presenter {

    . . .

    public void assignSaveHandler() {
        view.getSavingButton().addClickHandler(new ClickHandler() {
            @Override public void onClick(ClickEvent event) {
                final ValidationConstraint constraint = view.validate();
                if (constraint == null) {
                    final ProfileBean profile = view.gatherFields();
                    updateProfile(profile);
                } else {
                    eventBus.displayMessage(MessageType.VALIDATION_ERROR, constraint.getLocalizedDescription());
                }
            }
        });
    }

    . . .

}

```

### Резюме

Мне хотелось вывести какой-то общий, в меру простой, паттерн, который поместился бы на одной (хоть и большой) диаграмме классов и был понятен с первого взгляда. Надеюсь это получилось.
