# Blocksworld Problem #

My problem is based on the classic problem called [blocksworld problem](https://en.wikipedia.org/wiki/Blocks_world#:~:text=In%20its%20basic%20form%2C%20the,different%20sizes%2C%20shapes%20and%20colors.).

In detail, my configuration is:
 
- There is a robot manipulator that has 4 available actions:
PICKUP, PUTDOWN, STACK, UNSTACK.

- There are blocks on a table

- There is a goal to be achieved

### The construction of the problem: ###

- Each block can be **clear** (the robot hand can take it) or vice versa, **not-clear**.

- Each block can be **on-table** or vice versa, **in-hand**.

- The robot hand may be **busy** (it is holding a block) or **free** (it holds nothing).

- The 4 actions are:

1) PICKUP (a block from the table):
     - preconditions: 
       - block **clear** 
       - block **on-table**
       - hand **free**
     - effects: 
       - block **not-clear** 
       - block **in-hand**
       - hand **busy**


2) PUTDOWN (put the block from the hand to the table):
     - preconditions: 
       - block **not-clear**  
       - block **in-hand** 
       - hand **busy**
     - effects: 
       - block **clear** 
       - block **on-table**
       - hand **free**


3) STACK (put block1 on top of block2):
     - preconditions: 
       - block1 **in-hand** 
       - block2 **clear** 
       - hand **busy**
     - effects: 
       - block2 **not-clear**
       - block1 **on** block2
       - block1 **clear**
       - hand **free**


4) UNSTACK (take block1, which is above block2):
     - preconditions: 
       - block2 **not-clear**
       - block1 **on** block2 
       - block1 **clear** 
       - hand **free**
     - effects: 
       - block1 **in-hand**
       - block2 **clear** 
       - hand **busy**

Basically the 4 actions mirror physics.

EG. 
If I want to take a block from the table, the block must be free (**clear**) and hand must be **free**.
If block A is **on** block B, then I can UNSTACK block A and getting block B **clear** and block A in hand.

Obviously, the PICKUP action is the opposite of PUTDOWN and are used to take/place a block from/on the table.
The STACK action is the opposite of UNSTACK and are used to put/take a block on/from another block.



### My Goal: ### 
Compared to the classic blockworld, that is to build one or more vertical stacks of blocks, 
I'm trying to solve any possible arrangement of the blocks.  
Thus, my work aims to take a final arrangement of the blocks as input and, 
through backward inference, obtain a single large BindLink 
that will contain the sequence of actions to be performed 
to move from the initial arrangement of the blocks to the desired one.


### Two Possible Implementations: ###
(note that I'm looking for an Atomese-pure implementation)

### 1. Model-Based ###

**Initial Set in the atomspace:**  
An external algorithm detects all the blocks present on the table and their arrangement.  
The model-based implementation tries to solve the problem using
- Inference rules based on the 4 actions allowed by the manipulator robot
- Block properties as defined at the beginning of this text

Examples of initial set with 4 blocks available (A, B, C, D):
- A on B on C, D on table
- A on D, B on C
- A, B, C, D on table
- and so on ...

So taking example A, B, C, D on table my initial atomspace will be about 

```scheme
(SetLink

    ; robot hand
    (InheritanceLink (stv 1 1)
        (ConceptNode "hand")
        (ConceptNode "robot"))
    (EvaluationLink (stv 1 1)
        (PredicateNode "free")
        (ConceptNode "hand"))

    ; block1
    (InheritanceLink (stv 1 1)
        (ConceptNode "block1")
        (ConceptNode "object"))
    (EvaluationLink (stv 1 1)
        (PredicateNode "clear")
        (ConceptNode "block1"))
    (EvaluationLink (stv 1 1)
        (PredicateNode "on-table")
        (ConceptNode "block1"))
        
    ; block2, block3, block4 (same as block1)
    ; ....
    
    ; differentiate the various blocks
    (NotLink (EqualLink (ConceptNode "block1") (ConceptNode "block2")))
    (NotLink (EqualLink (ConceptNode "block1") (ConceptNode "block3")))
    (NotLink (EqualLink (ConceptNode "block1") (ConceptNode "block4")))
    ; ....
)
```

**Goal Implementation:**  
Each block will always be on top of something (table or other block).   
For example, if a possible goal is: block2 **on-table**, block1 **on** block3,  
then a possible Atomese goal formulation would be like:  


```scheme
(define rbs (ConceptNode "blocks-world"))

(define (compute_goal)
   (define goal-state
      (AndLink
         (EvaluationLink
            (PredicateNode "on-table")
            (VariableNode "$A")
         )
         (ListLink
            (VariableNode "$B")
            (VariableNode "$C")
         )
         (NotLink (EqualLink (VariableNode "$A") (VariableNode "$B")))
         (NotLink (EqualLink (VariableNode "$A") (VariableNode "$C")))
         (NotLink (EqualLink (VariableNode "$B") (VariableNode "$C")))
      )
   )
   (define vardecl
      (VariableList
         (TypedVariableLink (VariableNode "$A") (TypeNode "ConceptNode"))
         (TypedVariableLink (VariableNode "$B") (TypeNode "ConceptNode"))
         (TypedVariableLink (VariableNode "$C") (TypeNode "ConceptNode"))
      )
   )
   (cog-bc rbs goal-state #: vardecl vardecl)
)
(define result (compute_goal))
(display result)(newline)
```
Notice that (ListLink (VariableNode "$B") (VariableNode "$C")) means that the $B block is on top of the $C block (STACK of $B on $C).  
Moreover, the backward inference will find ALL possible combinations of blocks that can be arranged in that way.  


**Inference rules:**  
Based on the definitions of the 4 actions given above, there should be a rule for each action, 
plus some auxiliary rule (like conjunction I think).  
In the file related to this approach there are all 4 rules, which match their definitions.  
This is an example of the STACK rule, that it would be something like:

```scheme
(define stack
   (BindLink
      (VariableList
         (TypedVariableLink (VariableNode "?ob") (TypeNode "ConceptNode"))
         (TypedVariableLink (VariableNode "?underob") (TypeNode "ConceptNode"))
      )
      (PresentLink
         (NotLink
            (EqualLink (VariableNode "?ob") (VariableNode "?underob")))
         (InheritanceLink
            (VariableNode "?ob")
            (ConceptNode "object"))
         (InheritanceLink
            (VariableNode "?underob")
            (ConceptNode "object"))
         (AndLink
            (EvaluationLink
               (PredicateNode "in-hand")
               (VariableNode "?ob"))
            (EvaluationLink
               (PredicateNode "clear")
               (VariableNode "?underob"))
         )
      )
      (ExecutionOutputLink
         (GroundedSchemaNode "scm: stack-action")
         (ListLink
            ; effect:
            (ListLink
               (VariableNode "?ob")
               (VariableNode "?underob")
            )
            ; precondition
            (AndLink
               (EvaluationLink
                  (PredicateNode "in-hand")
                  (VariableNode "?ob"))
               (EvaluationLink
                  (PredicateNode "clear")
                  (VariableNode "?underob"))
            )
         )
      )
   )
)
```

## RUN: ##
- first terminal: 
cogserver

- second terminal: 
rlwrap telnet localhost 17001; (load "path/to/file/test_pickup_stack.scm");





3) Before talking about the problems that this writing (and the state-based alternative) has, I would like to talk about backward inference.

Probably the implementation and functioning of URE is my biggest shortcoming 
and also the reason why I don't find the right way to formulate and solve this problem. Some questions:

3.1) I've always seen backward inference work via BindLink and VariableNode. I have no idea if there is an alternative/better way to do it.

3.2) As Linas mentioned, BindLink requires PresentLink and this is one of the biggest problems. 
By backward inference the rules are called and combine into a large BindLink and the same is true for the PresentLink. 
In the end, you get a large PresentLink made up of all the PresentLinks of the called rules.
This means that for example I cannot use atoms like

; atom [0]
(EvaluationLink
               (PredicateNode "clear")
               (VariableNode "? Ob"))
; atom [1]
(EvaluationLink
               (PredicateNode "not-clear")
               (VariableNode "? Ob"))

because it doesn't make sense that the same block is both **clear** and **not-clear**.

----------------------
PS. this leads to another question: is what I am saying correct? I'll explain:
Suppose I have 2 rules. One has the atom [0] in the PresentLink and the other has the atom [1].
Suppose the rules are called in succession from backward inference.
When is PresentLink evaluated? From what I've seen:

1) the two rules compose the new BindLink, containing the PresentLink of both (which I think is the "Expanded forward chainer strategy")
2) The BindLink is evaluated and then the solutions are found or not (which I think is the "Selected and-BIT for fulfillment")

Then, only at the end, the PresentLink is evaluated, this implies that both atoms [0] and [1] must be present together in the atomspace.

This is incorrect: "The PresentLink of each rule is evaluated when that rule is called." Right?
----------------------

That said, it wouldn't seem like a problem. Instead it is, 
because it means that once the rule writes a new atom into the atomspace 
then that atom will always be present and therefore the rule that uses that atom as a precondition can be called whenever it wants.
Consequently , in example:

- blocks A, B, C
- initial arrangement: A **on** B, C on the table
- goal: Variable ?ob **on** Variable ?underob

Consequently, for example, the use of certain atoms is no longer good for trying to follow the physics of actions 
(eg hand- **busy** and hand- **free**: I can only take an object if my hand is free). 
The two atoms will always appear in the PresentLink and therefore, after doing a PICKUP and a PUTDOWN, 
I can do two PICKUP in a row without worrying about having to put the object down first.
So, you don't understand anything.
But essentially the presence of certain atoms to limit the solutions to only physically correct sequences of actions does not work (or at least I have not been able to find a logic that fits).


3.3) Mirror problem with unstack rule:

First let's take a step back: 

- blocks A, B, C
- initial arrangement: A, B, C on the table
- goal:
            (AndLink
               (ListLink
                  (VariableNode "?ob")
                  (VariableNode "?underob")
               )
               (NotLink (EqualLink (VariableNode "?ob") (VariableNode "?underob")))
            )


Backward inference could call the following rules in order: (conjunction joins two Links in a AndLink)

(goal) <- conjunction <- stack <- conjunction <- pickup <- (init-set)



(EvaluationLink (PredicateNode "clear")(VariableNode "?ob"))
----------------------------------------pickup-action----------------------------------------
(EvaluationLink (PredicateNode "in-hand") (VariableNode "?ob"))                                                 (EvaluationLink (PredicateNode "clear")(VariableNode "?underob"))
==========================================================conjunction============================================================
                                                                                                 (AndLink
                                                                                                      (EvaluationLink
                                                                                                         (PredicateNode "in-hand")
                                                                                                         (VariableNode "?ob"))
                                                                                                      (EvaluationLink
                                                                                                         (PredicateNode "clear")
                                                                                                         (VariableNode "?underob"))
                                                                                                 )
------------------------------------------------------------------------------------------------------- stack-action ----------------------------------
                                                                                                 (ListLink
                                                                                                    (VariableNode "?ob")                                             
                                                                                                    (VariableNode "?underob")                                                               (NotLink (EqualLink (VariableNode "?ob") (VariableNode "?underob")))
==========================================================conjunction=========================================================================================
                                                                                                             (AndLink
                                                                                                                (ListLink
                                                                                                                   (VariableNode "?ob")
                                                                                                                   (VariableNode "?underob")
                                                                                                                )
                                                                                                                (NotLink (EqualLink (VariableNode "?ob") (VariableNode "?underob")))
                                                                                                             )


and returns as a solution all the combinations of the 3 blocks one above the other two by two. 
This is great, but analyzing the rules, then "unstack" would be of the form:


                                                                                                 (ListLink
                                                                                                    (VariableNode "?ob")
                                                                                                    (VariableNode "?underob")     
----------------------------------------------------------------------------------------------------------------- unstack-action -----------------------------------------------------------------------------------------------------------------
                                                                                                 (AndLink
                                                                                                      (EvaluationLink
                                                                                                         (PredicateNode "in-hand")
                                                                                                         (VariableNode "?ob"))
                                                                                                      (EvaluationLink
                                                                                                         (PredicateNode "clear")
                                                                                                         (VariableNode "?underob"))
                                                                                                 )


and now the trouble begins, because, as for the conjunction rule used for stack, then I need a disjunction for unstack rule, 

                                                                                                 (AndLink
                                                                                                      (EvaluationLink
                                                                                                         (PredicateNode "in-hand")
                                                                                                         (VariableNode "?ob"))
                                                                                                      (EvaluationLink
                                                                                                         (PredicateNode "clear")
                                                                                                         (VariableNode "?underob"))
                                                                                                 )
==========================================================disjunction============================================================
(EvaluationLink (PredicateNode "in-hand") (VariableNode "?ob"))                                                 (EvaluationLink (PredicateNode "clear")(VariableNode "?underob"))


Which from what I know is not possible to have because there is always a single atom as an effect and a single atom as a precondition.
But there should be something like the composition rule:

Γ′⊢ψ                      Γ, ψ, Γ ”⊢ ∇
--------------------------------------------------
           Γ, Γ ′, Γ′′⊢ ∇




3.4) Finally, the last and I think the most important question: let's try to work by states.
Well, I have tried many ways and I have not succeeded in any.
Basically I found some shortcomings rather than logical errors.

As has been said, the number of states for this problem is large to have them all in the atomspace (especially if we use a lot of blocks) and a waste because, based on the goal, 3/4 of the states would be useless.

So there are 2 ideas (always in Atomese-pure):

1) Find a rule that takes in (precondition) a state and an action and returns (effect) a new state.

2) Find 4 rules (one for each action) that take in (precondition) a state and return (effect) a new one.

So, first of all:

- I could not give as a precondition: the last state created.
The preconditions and effects of the rules are non-generic atoms. The only possibility I had thought was to have the input state as VariableNode, so that with fulfillment it would try all the atoms that represented my states.
But this is not good because maybe after n actions, instead of taking the n-th state and creating the n + 1-th state, it could take the i-th state and create the n + 1-th state. And of course it is wrong because the i-th state is old and the layout of the blocks has certainly changed. (I hope it's clear enough)

This led me to think that StateLink was a good atom for this purpose.
- StateLink is unique, so it's fine as a precondition of my rule because it will definitely always represent the current situation of my blocks.
Yet when I get a sequence of states as a solution to my inference, then in the PresentLink of my final BindLink all these states are required to be present in the atomspace. And this does not work (always confirming my initial assumption that the presence in the atomspace of the atoms contained in the PresentLink is verified at the time of fulfillment and not at the call of each rule), because all the StateLinks prior to the last one no longer exist, for StateLink definition.

- I tried associating a Floats Value to the StateLink to represent the state of each block, so for example for each block one bit for "clear" / "not-clear", one bit for "in-hand" / "not-in -hand ", etc ...
The idea was to change the status bits of an object as a rule was called on that object.
 I guess that's not good because:
   - either the bits of the Value are the precondition and the effect of the rule, or the inference does not perceive their change during the calls of the various rules (if for example the flips of the bits occur in the GroundedSchemaNode)
   - even if the bits of the Value were the precondition and the effect of the rule, there would still be the PresentLink problem. So once I have created the "can-pickup" state of block A, it will always be usable because it is inserted in the atomspace, even when A is no longer "pickable".





4) Conclusions:
I think something is missing from the current system to solve this problem (or I need some advice because I can't do it in any way)

- The idea is a StateLink which however does not delete its old state but which keeps it in the atomspace. But somehow it can be called generically as a precondition of the rules, and this generic call always refers to the last StateLink created. (I saw that there was an obsolete atom: LatestLink, which maybe took over part of this operation)
  
So the operation would be (call this new atom LatestStateLink):

(define choose-action
   (BindLink
      (VariableList
         (TypedVariableLink (VariableNode "?ob") (TypeNode "ConceptNode"))
      ) 
      (PresentLink
         (InheritanceLink
            (VariableNode "?ob")
            (ConceptNode "object"))
         
         (LatestStateLink "actual_state"
               (ListLink (ConceptNode "?ob") (PredicateNode "state"))
               (FloatValue 0 1 0 .....)
            )
      
      )
      (ExecutionOutputLink
         (GroundedSchemaNode "scm: action")
         (ListLink
            ; effect:             
            (LatestStateLink "actual_state"
               (ListLink (ConceptNode "?ob") (PredicateNode "state"))
               (FloatValue 1 1 1 .....)
            )
            ; precondition
            (LatestStateLink "actual_state"
               (ListLink (ConceptNode "?ob") (PredicateNode "state"))
               (FloatValue 0 1 0 .....)
            )
         )
      )
   )
)

This is very similar to StateLink except for the name given to LatestStateLink. The idea is that the precondition for this rule is to check only the last state relative to the ?ob block and not the previous ones as well. If the last state, which I named "actual_state", has the FloatValue ​​corresponding to the required ones then the rule can be called, otherwise not.

When the rule is called the effect is written on the atomspace and then a new LatestStateLink "actual_state" is added and the previous LatestStateLink is left in the atomspace losing the name (so that you have one and only one "actual_state").

By doing this, it is possible to write rules in a generic way that respect the physics of actions and function in states.
it's just a draft it will probably have other errors but it was one of the ideas that came to me.