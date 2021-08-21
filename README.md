# Blocksworld Problem #

My problem is based on the classic problem called [blocksworld problem](https://en.wikipedia.org/wiki/Blocks_world#:~:text=In%20its%20basic%20form%2C%20the,different%20sizes%2C%20shapes%20and%20colors.).  
There is also the definition of the problem in the PDDL format in the domain.pddl and problem.pddl files

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

### 1. Model-Based (the file is missing, I will upload it soon) ###

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


### 2. States-Based (file Blocksworld_FSM.scm) ###
This approach is simply a finite state machine (FSM), for now not even probabilistic (if I understand correctly).  
The starting point are the following examples:

https://github.com/opencog/atomspace/blob/master/examples/pattern-matcher/fsm-basic.scm
https://github.com/opencog/atomspace/blob/master/examples/pattern-matcher/fsm-full.scm
https://github.com/opencog/atomspace/blob/master/examples/pattern-matcher/fsm-mealy.scm
https://github.com/opencog/atomspace/blob/master/examples/pattern-matcher/markov-chain.scm

This is probably the best way to solve my problem.
Unfortunately it's necessary to define in advance all the states and all the possible transitions between the various states. 
Now, we are in a limited domain so the states are known, each represents a different arrangement of the blocks,
so they are the combinations of the n blocks arranged in a limited number of ways, 
the same holds for the transition functions between one state to another.


**Initial Set in the atomspace:**  

Example with only 2 blocks (A and B):

```scheme
;; All possible states
(Concept "initial state")
(Concept "A B clear")
(Concept "A in hand B clear")
(Concept "B in hand A clear")
(Concept "A on B")
(Concept "B on A")

;; All possible transition from a state to another

(List                                   ; pickup A
    (Concept "A B clear")
    (Concept "A in hand B clear"))
(List                                   ; pickup B
    (Concept "A B clear")
    (Concept "B in hand A clear"))
(List                                   ; putdown A
    (Concept "A in hand B clear")
    (Concept "A B clear"))
(List                                   ; putdown B
    (Concept "B in hand A clear")
    (Concept "A B clear"))
(List                                   ; stack A on B
    (Concept "A in hand B clear")
    (Concept "A on B"))
(List                                   ; stack B on A
    (Concept "B in hand A clear")
    (Concept "B on A"))
(List                                   ; unstack A on B
    (Concept "A on B")          
    (Concept "A in hand B clear"))
(List                                   ; unstack B on A
    (Concept "B on A")
    (Concept "B in hand A clear"))
    
    
;; Lock the initial state with the Anchor "Current State"
;; and create the first transition function from "initial state" to the to the actual one (in this case "A B clear")
(List
    (Anchor "Current State")
    (Concept "initial state"))
(List
    (Concept "initial state")
    (Concept "A B clear"))

;; List of old states crossed
(ListLink
    (Concept "initial state"))
```

**Goal Implementation:**  
The goal will be one of the states (i.e. a certain arrangement of the blocks) 
and the list of states to go through to reach it.
I thought something like this:

```scheme
(define rbs (ConceptNode "blocks-world"))

(define (compute_goal)
    (define goal-state
        (AndLink
            (ListLink
                (AnchorNode "Current State")
                (ConceptNode "A on B")          ; my goal state (in this case)
            )
            (VariableNode "$all_old_states")
        )
    )
    (define vardecl
        (VariableList
            (TypedVariableLink (VariableNode "$all_old_states") (TypeNode "ListLink"))
        )
    )
    (cog-bc rbs goal-state #:vardecl vardecl)
)

(define result (compute_goal))
(display result)(newline)
```
Before explaining how it works, let's define the last thing that is the inference rules.

**Inference rules:**  
There are only 2 rules:

1. "Take-one-step" rule:
It coincides with the rule of the examples linked above, 
the only difference is that it does not delete the old current state when it takes a step forward and
also contains the list of past states.

```scheme
(define take-one-step  
    (BindLink
        (VariableList
            (TypedVariableLink (VariableNode "$old-states") (TypeNode "ListLink"))
            (TypedVariableLink (VariableNode "$curr-state") (TypeNode "ConceptNode"))
            (TypedVariableLink (VariableNode "$next-state") (TypeNode "ConceptNode"))
        )
    (AndLink
        (NotLink
            (MemberLink
                (VariableNode "$next-state")
                    ;; ERROR: This pattern match should be limited to the "$old-states" variable 
                    (BindLink
                        (VariableList
                            (TypedVariableLink (VariableNode "$A") (TypeNode "ConceptNode"))
                            (TypedVariableLink (VariableNode "$B") (TypeNode "ListLink"))
                        )
                        (ListLink
                            (VariableNode "$A")
                            (VariableNode "$B")
                        )
                        (VariableNode "$A")
                    )
                )
            )
            (PresentLink
                (AndLink
                    (ListLink
                        (AnchorNode "Current State")
                        (VariableNode "$curr-state")
                    )
                    (ListLink
                        (VariableNode "$curr-state")
                        (VariableNode "$next-state")
                    )
                    (VariableNode "$old-states")
                )
            )
        )
        (ExecutionOutputLink
            (GroundedSchemaNode "scm: action_step")
            (ListLink
                ;; ... then transition to the next state ...
                (AndLink
                    (ListLink
                        (AnchorNode "Current State")
                        (VariableNode "$next-state")
                    )
                    (VariableNode "$old-states")
                )
                (AndLink
                    ;; If we are in the current state ...
                    (ListLink
                        (AnchorNode "Current State")
                        (VariableNode "$curr-state")
                    )
                    ;; ... and there is a transition to another state...
                    (ListLink
                        (VariableNode "$curr-state")
                        (VariableNode "$next-state")
                    )
                    (VariableNode "$old-states")
                )
            )
        )
    )
)
```

2. "add-old-state" rule:
It takes the effect of the first rule and adds the new transition function and 
also adds the current state to the list of past states.  
In this way the first rule, with all the correct preconditions, can be called again and
so on with these two rules...

```scheme
(define add-old-state
    (let* ((variables (gen-variables "$X" 3))
        (vardecl 
            (VariableList
                (TypedVariableLink (car variables) (TypeNode "ListLink"))
                (TypedVariableLink (car (cdr variables)) (TypeNode "ConceptNode"))
                (TypedVariableLink (car (cdr (cdr variables))) (TypeNode "ConceptNode"))
            )
        )
        (pattern
            (PresentLink
                (And
                    (ListLink
                        (AnchorNode "Current State")
                        (car (cdr variables))
                    )
                    (ListLink
                        (car (cdr variables))
                        (car (cdr (cdr variables)))
                    )
                    (car variables)
                )
            )
        )
        (rewrite 
            (ExecutionOutput
                (GroundedSchema "scm: conjunction")
                (List
                    (And
                        (ListLink
                            (AnchorNode "Current State")
                            (car (cdr variables))
                        )
                        (ListLink
                            (car (cdr variables))
                            (car (cdr (cdr variables)))
                        )
                        (List (car (cdr variables)) (car variables))
                    )
                    (And
                        (ListLink
                            (AnchorNode "Current State")
                            (car (cdr variables))
                        )
                        (car variables)
                    )
                )
            )
        ))
        (Bind
            vardecl
            pattern
            rewrite
        )
    )
)
```


### IMPORTANT ###  
Finally we come to the reasons for this structure. 
The main idea of this implementation is that these two rules are called "infinitely" one after the other. 
At each iteration, the path (≡ height of the derivation tree ≡ number of past states) increases by one state. 
Moreover, from any state it is always possible to reach all the others in a finite number of steps. 
This means that, with a sufficiently large number of iterations of the backward inference, 
I will surely reach the correct length of the optimal path to pass from the starting state to the goal state.

I've got an aside: I'm talking about an optimal path because the backward inference with variable filling 
will surely find as the first solution (if it works) the path of minimum length, that is, 
the one that avoids passing through useless states. 
This is because the backward inference tries to replace all the variables with the available values and
therefore it will necessarily also find the optimal solution.

#### On a practical level: ####  
The backward inference will create a big BindLink containing all the calls to the rules etc ...
This means I can't use code like (cog-outgoing-atom) and all such functions, but I have to limit to atoms.
This is the reason that makes the rules a little complicated and cumbersome.
The main point of this is the "old-states" list.
To find the optimal path of states to go through to reach my goal, I need to never go through the same state twice.
So everytime I take a step, I have to check that the next state is not contained in the list of past states (the NotLink in the conditions of the first rule). 
But this list changes as rules are called! However, these changes don't happen when I do backward inference because the execution will happen upon completion of the single final large BindLink.  
Consequently this list must necessarily be a VariableNode that I bring with me in each call of the rule until the final goal.   
And how should it be built?
I believed this way:

```scheme
(List
    (Concept "state-N")
    (List

      ;.........

        (Concept "state-2")
        (List
            (Concept "state-1")
            (List
                (Concept "initial state")
            )
        )
    )
)
```
Thus, in the evaluation of the conditions of the final BindLink, there will be the contrasts between each next_state and the previous ones relating to that state.
Practically, each list for each take-one-step:

```scheme
;; variable "$old-state-1"
(List
    (Concept "initial state")
)

;; variable "$old-state-2"
(List
    (Concept "1")
    (Variable "$old-state-1")
)

;; variable "$old-state-3"
(List
    (Concept "2")
    (Variable "$old-state-2")
)

;; and so on until final state
(List
    (Concept "final_state")
    (Variable "$old-state-n")
)
```

and so the final conditions in the last BindLink, it should be / I would like it to be:

```scheme
(AndLink
    (NotLink
        (MemberLink
            (VariableNode "$next-state-1")
            (VariableNode "$old-state-1")
        )
    )
    (NotLink
        (MemberLink
            (VariableNode "$next-state-2")
            (VariableNode "$old-state-2")
        )
    )
    (NotLink
        (MemberLink
            (VariableNode "$next-state-3")
            (VariableNode "$old-state-3")
        )
    )
    
;; ......
```

(This is because I have not found a better way I think)  
This is the reason for the NotLink built that way within the first rule. It should extract the ConceptNode states from the ListLinks which corresponds to the relative "old-states-i" variable but I don't know how to do it.
I also don't know if this is conceptually correct.

I haven't achieved a satisfactory result in either of the two implementations yet.

## RUN: ##
- first terminal: 
cogserver

- second terminal: 
rlwrap telnet localhost 17001; (load "path/to/file/Blocksworld_FSM.scm");
