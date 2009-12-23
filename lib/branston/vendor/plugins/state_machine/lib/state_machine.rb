require 'state_machine/machine'

# A state machine is a model of behavior composed of states, events, and
# transitions.  This helper adds support for defining this type of
# functionality on any Ruby class.
module StateMachine
  module MacroMethods
    # Creates a new state machine with the given name.  The default name, if not
    # specified, is <tt>:state</tt>.
    # 
    # Configuration options:
    # * <tt>:attribute</tt> - The name of the attribute to store the state value
    #   in.  By default, this is the same as the name of the machine.
    # * <tt>:initial</tt> - The initial state of the attribute. This can be a
    #   static state or a lambda block which will be evaluated at runtime
    #   (e.g. lambda {|vehicle| vehicle.speed == 0 ? :parked : :idling}).
    #   Default is nil.
    # * <tt>:action</tt> - The instance method to invoke when an object
    #   transitions. Default is nil unless otherwise specified by the
    #   configured integration.
    # * <tt>:namespace</tt> - The name to use for namespacing all generated
    #   state / event instance methods (e.g. "heater" would generate
    #   :turn_on_heater and :turn_off_heater for the :turn_on/:turn_off events).
    #   Default is nil.
    # * <tt>:integration</tt> - The name of the integration to use for adding
    #   library-specific behavior to the machine.  Built-in integrations
    #   include :data_mapper, :active_record, and :sequel.  By default, this
    #   is determined automatically.
    # 
    # Configuration options relevant to ORM integrations:
    # * <tt>:plural</tt> - The pluralized name of the attribute.  By default,
    #   this will attempt to call +pluralize+ on the attribute.  If this
    #   method is not available, an "s" is appended.  This is used for
    #   generating scopes.
    # * <tt>:messages</tt> - The error messages to use when invalidating
    #   objects due to failed transitions.  Messages include:
    #   * <tt>:invalid</tt>
    #   * <tt>:invalid_event</tt>
    #   * <tt>:invalid_transition</tt>
    # * <tt>:use_transactions</tt> - Whether transactions should be used when
    #   firing events.  Default is true unless otherwise specified by the
    #   configured integration.
    # 
    # This also expects a block which will be used to actually configure the
    # states, events and transitions for the state machine.  *Note* that this
    # block will be executed within the context of the state machine.  As a
    # result, you will not be able to access any class methods unless you refer
    # to them directly (i.e. specifying the class name).
    # 
    # For examples on the types of state machine configurations and blocks, see
    # the section below.
    # 
    # == Examples
    # 
    # With the default name/attribute and no configuration:
    # 
    #   class Vehicle
    #     state_machine do
    #       event :park do
    #         ...
    #       end
    #     end
    #   end
    # 
    # The above example will define a state machine named "state" that will
    # store the value in the +state+ attribute.  Every vehicle will start
    # without an initial state.
    # 
    # With a custom name / attribute:
    # 
    #   class Vehicle
    #     state_machine :status, :attribute => :status_value do
    #       ...
    #     end
    #   end
    # 
    # With a static initial state:
    # 
    #   class Vehicle
    #     state_machine :status, :initial => :parked do
    #       ...
    #     end
    #   end
    # 
    # With a dynamic initial state:
    # 
    #   class Vehicle
    #     state_machine :status, :initial => lambda {|vehicle| vehicle.speed == 0 ? :parked : :idling} do
    #       ...
    #     end
    #   end
    # 
    # == Instance Methods
    # 
    # The following instance methods will be automatically generated by the
    # state machine based on the *name* of the machine.  Any existing methods
    # will not be overwritten.
    # * <tt>state</tt> - Gets the current value for the attribute
    # * <tt>state=(value)</tt> - Sets the current value for the attribute
    # * <tt>state?(name)</tt> - Checks the given state name against the current
    #   state.  If the name is not a known state, then an ArgumentError is raised.
    # * <tt>state_name</tt> - Gets the name of the state for the current value
    # * <tt>state_events</tt> - Gets the list of events that can be fired on
    #   the current object's state (uses the *unqualified* event names)
    # * <tt>state_transitions(requirements = {})</tt> - Gets the list of possible
    #   transitions that can be made on the current object's state.  Additional
    #   requirements, such as the :from / :to state and :on event can be specified
    #   to restrict the transitions to select.  By default, the current state
    #   will be used for the :from state.
    # 
    # For example,
    # 
    #   class Vehicle
    #     state_machine :state, :initial => :parked do
    #       event :ignite do
    #         transition :parked => :idling
    #       end
    #       
    #       event :park do
    #         transition :idling => :parked
    #       end
    #     end
    #   end
    #   
    #   vehicle = Vehicle.new
    #   vehicle.state                     # => "parked"
    #   vehicle.state_name                # => :parked
    #   vehicle.state?(:parked)           # => true
    #   
    #   # Changing state
    #   vehicle.state = 'idling'
    #   vehicle.state                     # => "idling"
    #   vehicle.state_name                # => :idling
    #   vehicle.state?(:parked)           # => false
    #   
    #   # Getting current event / transition availability
    #   vehicle.state_events              # => [:park]
    #   vehicle.park                      # => true
    #   vehicle.state_events              # => [:ignite]
    #   
    #   vehicle.state_transitions         # => [#<StateMachine::Transition attribute=:state event=:ignite from="parked" from_name=:parked to="idling" to_name=:idling>]
    #   vehicle.ignite
    #   vehicle.state_transitions         # => [#<StateMachine::Transition attribute=:state event=:park from="idling" from_name=:idling to="parked" to_name=:parked>]
    # 
    # == Attribute initialization
    # 
    # For most classes, the initial values for state machine attributes are
    # automatically assigned when a new object is created.  However, this
    # behavior will *not* work if the class defines an +initialize+ method
    # without properly calling +super+.
    # 
    # For example,
    # 
    #   class Vehicle
    #     state_machine :state, :initial => :parked do
    #       ...
    #     end
    #   end
    #   
    #   vehicle = Vehicle.new   # => #<Vehicle:0xb7c8dbf8 @state="parked">
    #   vehicle.state           # => "parked"
    # 
    # In the above example, no +initialize+ method is defined.  As a result,
    # the default behavior of initializing the state machine attributes is used.
    # 
    # In the following example, a custom +initialize+ method is defined:
    # 
    #   class Vehicle
    #     state_machine :state, :initial => :parked do
    #       ...
    #     end
    #     
    #     def initialize
    #     end
    #   end
    #   
    #   vehicle = Vehicle.new   # => #<Vehicle:0xb7c77678>
    #   vehicle.state           # => nil
    # 
    # Since the +initialize+ method is defined, the state machine attributes
    # never get initialized.  In order to ensure that all initialization hooks
    # are called, the custom method *must* call +super+ without any arguments
    # like so:
    # 
    #   class Vehicle
    #     state_machine :state, :initial => :parked do
    #       ...
    #     end
    #     
    #     def initialize(attributes = {})
    #       ...
    #       super()
    #     end
    #   end
    #   
    #   vehicle = Vehicle.new   # => #<Vehicle:0xb7c8dbf8 @state="parked">
    #   vehicle.state           # => "parked"
    # 
    # Because of the way the inclusion of modules works in Ruby, calling
    # <tt>super()</tt> will not only call the superclass's +initialize+, but
    # also +initialize+ on all included modules.  This allows the original state
    # machine hook to get called properly.
    # 
    # If you want to avoid calling the superclass's constructor, but still want
    # to initialize the state machine attributes:
    # 
    #   class Vehicle
    #     state_machine :state, :initial => :parked do
    #       ...
    #     end
    #     
    #     def initialize(attributes = {})
    #       ...
    #       initialize_state_machines
    #     end
    #   end
    #   
    #   vehicle = Vehicle.new   # => #<Vehicle:0xb7c8dbf8 @state="parked">
    #   vehicle.state           # => "parked"
    # 
    # == States
    # 
    # All of the valid states for the machine are automatically tracked based
    # on the events, transitions, and callbacks defined for the machine.  If
    # there are additional states that are never referenced, these should be
    # explicitly added using the StateMachine::Machine#state or
    # StateMachine::Machine#other_states helpers.
    # 
    # When a new state is defined, a predicate method for that state is
    # generated on the class.  For example,
    # 
    #   class Vehicle
    #     state_machine :initial => :parked do
    #       event :ignite do
    #         transition all => :idling
    #       end
    #     end
    #   end
    # 
    # ...will generate the following instance methods (assuming they're not
    # already defined in the class):
    # * <tt>parked?</tt>
    # * <tt>idling?</tt>
    # 
    # Each predicate method will return true if it matches the object's
    # current state.  Otherwise, it will return false.
    # 
    # == Events and Transitions
    # 
    # Events defined on the machine are the interface to transitioning states
    # for an object.  Events can be fired either directly (through the method
    # generated for the event) or indirectly (through attributes defined on
    # the machine).
    # 
    # For example,
    # 
    #   class Vehicle
    #     include DataMapper::Resource
    #     property :id, Serial
    #     
    #     state_machine :initial => :parked do
    #       event :ignite do
    #         transition :parked => :idling
    #       end
    #     end
    #     
    #     state_machine :alarm_state, :initial => :active do
    #       event :disable do
    #         transition all => :off
    #       end
    #     end
    #   end
    #   
    #   # Fire +ignite+ event directly
    #   vehicle = Vehicle.create    # => #<Vehicle id=1 state="parked" alarm_state="active">
    #   vehicle.ignite              # => true
    #   vehicle.state               # => "idling"
    #   vehicle.alarm_state         # => "active"
    #   
    #   # Fire +disable+ event automatically
    #   vehicle.alarm_state_event = 'disable'
    #   vehicle.save                # => true
    #   vehicle.alarm_state         # => "off"
    # 
    # In the above example, the +state+ attribute is transitioned using the
    # +ignite+ action that's generated from the state machine.  On the other
    # hand, the +alarm_state+ attribute is transitioned using the +alarm_state_event+
    # attribute that automatically gets fired when the machine's action (+save+)
    # is invoked.
    # 
    # For more information about how to configure an event and its associated
    # transitions, see StateMachine::Machine#event.
    # 
    # == Defining callbacks
    # 
    # Within the +state_machine+ block, you can also define callbacks for
    # transitions.  For more information about defining these callbacks,
    # see StateMachine::Machine#before_transition and
    # StateMachine::Machine#after_transition.
    # 
    # == Namespaces
    # 
    # When a namespace is configured for a state machine, the name provided
    # will be used in generating the instance methods for interacting with
    # states/events in the machine.  This is particularly useful when a class
    # has multiple state machines and it would be difficult to differentiate
    # between the various states / events.
    # 
    # For example,
    # 
    #   class Vehicle
    #     state_machine :heater_state, :initial => :off, :namespace => 'heater' do
    #       event :turn_on do
    #         transition all => :on
    #       end
    #       
    #       event :turn_off do
    #         transition all => :off
    #       end
    #     end
    #     
    #     state_machine :alarm_state, :initial => :active, :namespace => 'alarm' do
    #       event :turn_on do
    #         transition all => :active
    #       end
    #       
    #       event :turn_off do
    #         transition all => :off
    #       end
    #     end
    #   end
    # 
    # The above class defines two state machines: +heater_state+ and +alarm_state+.
    # For the +heater_state+ machine, the following methods are generated since
    # it's namespaced by "heater":
    # * <tt>can_turn_on_heater?</tt>
    # * <tt>turn_on_heater</tt>
    # * ...
    # * <tt>can_turn_off_heater?</tt>
    # * <tt>turn_off_heater</tt>
    # * ..
    # * <tt>heater_off?</tt>
    # * <tt>heater_on?</tt>
    # 
    # As shown, each method is unique to the state machine so that the states
    # and events don't conflict.  The same goes for the +alarm_state+ machine:
    # * <tt>can_turn_on_alarm?</tt>
    # * <tt>turn_on_alarm</tt>
    # * ...
    # * <tt>can_turn_off_alarm?</tt>
    # * <tt>turn_off_alarm</tt>
    # * ..
    # * <tt>alarm_active?</tt>
    # * <tt>alarm_off?</tt>
    # 
    # == Scopes
    # 
    # For integrations that support it, a group of default scope filters will
    # be automatically created for assisting in finding objects that have the
    # attribute set to one of a given set of states.
    # 
    # For example,
    # 
    #   Vehicle.with_state(:parked)               # => All vehicles where the state is parked
    #   Vehicle.with_states(:parked, :idling)     # => All vehicles where the state is either parked or idling
    #   
    #   Vehicle.without_state(:parked)            # => All vehicles where the state is *not* parked
    #   Vehicle.without_states(:parked, :idling)  # => All vehicles where the state is *not* parked or idling
    # 
    # *Note* that if class methods already exist with those names (i.e.
    # :with_state, :with_states, :without_state, or :without_states), then a
    # scope will not be defined for that name.
    # 
    # See StateMachine::Machine for more information about using integrations
    # and the individual integration docs for information about the actual
    # scopes that are generated.
    def state_machine(*args, &block)
      StateMachine::Machine.find_or_create(self, *args, &block)
    end
  end
end

Class.class_eval do
  include StateMachine::MacroMethods
end

# Register rake tasks for supported libraries
Merb::Plugins.add_rakefiles("#{File.dirname(__FILE__)}/../tasks/state_machine") if defined?(Merb::Plugins)
