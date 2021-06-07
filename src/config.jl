"""
RuleConfig{F, R, T}

The configuration
- `F`: **frule-like**. This is singleton `typeof` a function which acts like `frule`, but
which functions via invoking an AD system. It must match the [`frule`](@ref) signature.
If you do not have such a function it must be set to `Nothing` instead.
- `R`: **rrule-like**. This is singleton `typeof` a function which acts like `rrule`, but
which functions via invoking an AD system. It must match the [`rrule`](@ref) signature.
If you do not have such a function it must be set to `Nothing` instead.
- `T`: **traits**. This should be a `Union` of all special traits needed for rules to be
allowed to be defined for your AD. If nothing special this should be set to `Union{}`.

Rule authors can dispatch on this config when defining rules.
For example:
```julia
# only define rrule for `pop!` on AD systems where mutation is supported.
rrule(::RuleConfig{<:Any,<:Any,>:SupportsMutation}, typeof(pop!), ::Vector) = ...

# this definition of map is for any AD that defines a forwards mode
rrule(conf::RuleConfig{<:Function}, typeof(map), ::Vector) = ...

# this definition of map is for any AD that only defines a reverse mode.
# It is not as good as the rrule that can be used if the AD defines a forward-mode as well.
rrule(conf::RuleConfig{Nothing,<:Function}, typeof(map), ::Vector) = ...
```

For more details see [rule configurations and calling back into AD](@ref config).
"""
abstract type RuleConfig{F<:Union{Function,Nothing}, R<:Union{Function,Nothing}, T} where T end


abstract type ReverseModeCapability end

"""
CanReverseMode

This trait indicates that a `RuleConfig{>:CanReverseMode}` can perform reverse mode AD.
If it is set then [`rrule_via_ad`](@ref) must be implemented.
"""
struct CanReverseMode <: ReverseModeCapability end

"""
NoReverseMode

This is the complement to [`CanReverseMode`](@ref). To avoid ambiguities [`RuleConfig`]s
that do not support performing reverse mode AD should be `RuleConfig{>:NoReverseMode}`.
"""
struct NoReverseMode <: ReverseModeCapability end

abstract type ForwardsModeCapability end

"""
CanForwardsMode

This trait indicates that a `RuleConfig{>:CanForwardsMode}` can perform forward mode AD.
If it is set then [`frule_via_ad`](@ref) must be implemented.
"""
struct CanForwardsMode <: ForwardsModeCapability end

"""
NoForwardsMode

This is the complement to [`CanForwardsMode`](@ref). To avoid ambiguities [`RuleConfig`]s
that do not support performing forwards mode AD should be `RuleConfig{>:NoForwardsMode}`.
"""
struct NoForwardsMode <: ForwardsModeCapability end


"""
frule_via_ad(::RuleConfig{>:CanForwardMode}, ārgs, f, args...; kwargs...)

This function has the same API as [`frule`](@ref), but operates via performing forwards mode
automatic differentiation.
Any `RuleConfig` subtype that supports the [`CanForwardMode`](@ref) special feature must
provide an implementation of it.

See also: [`rrule_via_ad`](@ref), [`RuleConfig`](@ref) and the documentation on
[rule configurations and calling back into AD](@ref config)
"""
function frule_via_ad end

"""
rrule_via_ad(::RuleConfig{>:CanReverseMode}, f, args...; kwargs...)

This function has the same API as [`rrule`](@ref), but operates via performing forwards mode
automatic differentiation.
Any `RuleConfig` subtype that supports the [`CanReverseMode`](@ref) special feature must
provide an implementation of it.

See also: [`frule_via_ad`](@ref), [`RuleConfig`](@ref) and the documentation on
[rule configurations and calling back into AD](@ref config)
"""
function rrule_via_ad end
