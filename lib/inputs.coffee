_ = require "lodash"
React = require "react"
cx = require "react/lib/cx"
ReactCSSTransitionGroup = require "react/lib/ReactCSSTransitionGroup"

{div, input, select, option, i, button} = React.DOM

monthMap = _.map [
  "January"
  "February"
  "March"
  "April"
  "May"
  "June"
  "July"
  "August"
  "September"
  "October"
  "November"
  "December"
], (month, n) -> [n, month]

# Month starts with 1
daysInMonth = (month, year) -> new Date(year, month, 0).getDate()

Input =
  propTypes:
    options: React.PropTypes.object
    value: React.PropTypes.any
    onChange: React.PropTypes.func
    status: React.PropTypes.string
    onFocus: React.PropTypes.func
    onBlur: React.PropTypes.func
    focus: React.PropTypes.bool
    valid: React.PropTypes.object
    showIndicators: React.PropTypes.bool

  shouldRenderIndicator: ->
    if @props.showIndicators
      return @props.valid?.valid
    else
      return null

  shouldRenderFormatting: ->
    @props.valid?.valid is false and not @props.valid?.interactive

Text =
  onChange: (e) ->
    @props.onChange e.target.value

  componentDidMount: ->
    @focus()

  componentDidUpdate: ->
    @focus()

  focus: ->
    _.defer => @refs.input.getDOMNode().focus() if @props.focus

  renderIndicator: ->
    result = @shouldRenderIndicator()

    if result is true
      indicator = i className: "form-field-indicator fa fa-check"
    else if result is false
      indicator = i className: "form-field-indicator fa fa-times"
    else
      indicator = null

    return ReactCSSTransitionGroup transitionName: "fade", indicator

  renderInput: (options) ->
    props = _.extend {},
      ref: "input"
      value: @props.value
      onChange: @onChange
      className: cx "error": @shouldRenderFormatting()
      placeholder: @props.options.placeholder
    , options

    return div className: "form-field",
      @transferPropsTo input props
      @renderIndicator()

TextInput = React.createClass
  displayName: "TextInput"
  mixins: [Input, Text]

  render: ->
    @renderInput()

PasswordInput = React.createClass
  displayName: "PasswordInput"
  mixins: [Input, Text]

  render: ->
    @renderInput type: "password"

DateInput = React.createClass
  displayName: "DateInput"
  mixins: [Input]

  getInitialState: ->
    date = new Date()
    return {
      value: @props.value
      currentYear: date.getFullYear()
    }

  onMonthChange: (e) ->
    month = parseInt e.target.value
    date = @state.value
    # Ensure that the day is valid with the selected month.
    # Correct the day if it is invalid.
    year = @state.value.getFullYear()
    date.setDate Math.min date.getDate(), daysInMonth month + 1, year
    date.setMonth month
    @setDate date

  onDayChange: (e) ->
    date = @state.value
    date.setDate parseInt e.target.value
    @setDate date

  onYearChange: (e) ->
    date = @state.value
    date.setFullYear parseInt e.target.value
    @setDate date

  setDate: (date) ->
    @setState {value: date}
    @props.onChange date

  renderMonthSelector: ->
    months = _.map monthMap, (month) -> option value: month[0], month[1]
    return select
      className: "input-date-month"
      value: @state.value.getMonth()
      onChange: @onMonthChange
    , months

  renderDaySelector: ->
    days = [1..daysInMonth(@state.value.getMonth() + 1, @state.value.getFullYear())]
    dayOptions = _.map days, (day) -> option value: day, day
    return select
      className: "input-date-day"
      value: @state.value.getDate()
      onChange: @onDayChange
    , dayOptions

  renderYearSelector: ->
    years = _.map [@state.currentYear..1900], (year) ->
      option value: year, year
    return select
      className: "input-date-year"
      value: @state.value.getFullYear()
      onChange: @onYearChange
    , years

  render: ->
    div className: "group input-date",
      @renderMonthSelector()
      @renderDaySelector()
      @renderYearSelector()

ChoiceInput = React.createClass
  displayName: "ChoiceInput"
  mixins: [Input]

  propTypes:
    choices: React.PropTypes.object.isRequired
    btnClass: React.PropTypes.string
    default: React.PropTypes.string

  getInitialState: ->
    value: null

  onChoiceSelect: (value) ->
    @setState {value}
    @props.onChange value

  render: ->
    btnClass = @props.btnClass or ""
    div className: "group", _.map @props.choices, (title, choice) =>
      button
        onClick: => @onChoiceSelect choice
        className: btnClass + " " + cx active: @state.value is choice
      , title

module.exports = {
  TextInput
  PasswordInput
  DateInput
  ChoiceInput
}
