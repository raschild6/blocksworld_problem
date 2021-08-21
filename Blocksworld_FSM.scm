(use-modules (opencog) (opencog ure) (opencog exec) (opencog pln) (opencog logger))

(cog-logger-set-level! (cog-ure-logger) "debug")

;; -------------------------------- Load Rules --------------------------------

;; SCM action
(define (action_step . args)
	(define effect (car args))
	effect
)
(define (conjunction . args)
	(let
		((tmp (car args)))
		tmp
	)
)


;; Take-One-State-Step rule:
;;
(define take-one-step
	(BindLink
		(VariableList
			(TypedVariableLink (VariableNode "$old-states") (TypeNode "ListLink"))
			(TypedVariableLink (VariableNode "$curr-state") (TypeNode "ConceptNode"))
	   	(TypedVariableLink (VariableNode "$next-state") (TypeNode "ConceptNode"))
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


;; Add-Current-State-To-Old-State-List rule:
;;
(define add-old-state
	(Bind
		(VariableList
			(TypedVariableLink (VariableNode "$old-states") (TypeNode "ListLink"))
			(TypedVariableLink (VariableNode "$curr-state") (TypeNode "ConceptNode"))
			(TypedVariableLink (VariableNode "$next-state") (TypeNode "ConceptNode"))
		)
		(And
			(NotLink
				(MemberLink
					(VariableNode "$next-state")
				  	;; ERROR: This pattern match should be into the "$old-states" variable (not on the Atomspace)
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
				;; check for an admissible transition function
				(ListLink
					(VariableNode "$curr-state")
					(VariableNode "$next-state")
				)
				(And
					(ListLink
						(AnchorNode "Current State")
						(VariableNode "$curr-state")
					)
					(VariableNode "$old-states")
				)
			)
		)
		(ExecutionOutput
			(GroundedSchema "scm: conjunction")
			(List
				(And
					(ListLink
						(AnchorNode "Current State")
						(VariableNode "$curr-state")
					)
					;; admissible transition function
					(ListLink
						(VariableNode "$curr-state")
						(VariableNode "$next-state")
					)
					;; add "curr-state" to the "old-state" list
					(List
						(VariableNode "$curr-state")
						(VariableNode "$old-states")
					)
				)
				(And
					(ListLink
						(AnchorNode "Current State")
						(VariableNode "$curr-state")
					)
					(VariableNode "$old-states")
				)
			)
		)
	)
)

(define rbs (ConceptNode "blocks-world"))

(define (add-to-rule-base bindlink name rbs)
	(DefineLink
   	(DefinedSchemaNode name)
      bindlink)
   (MemberLink (stv 1 0.01)
   	(DefinedSchemaNode name)
   	rbs)
)

(add-to-rule-base take-one-step "take-one-step" rbs)
(add-to-rule-base add-old-state "add-old-state" rbs)



;; -------------------------------- Initial Knowledge Base --------------------------------

;; All possible states
(Concept "initial state")
(Concept "A B clear")
(Concept "A in hand B clear")
(Concept "B in hand A clear")
(Concept "A on B")
(Concept "B on A")

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
(List
	(Anchor "Current State")
	(Concept "initial state"))
;; add the first transition function from fake state ("initial state") to the real state (for example "A B clear")
(List
	(Concept "initial state")
	(Concept "A B clear"))

;; List of old states crossed
(List
	(Concept "initial state")
	(List))


;; ----------- URE parameters -----------
(ure-set-maximum-iterations rbs 50)
; positive: breadth first - negative: depth first - 0: neutral
(ure-set-complexity-penalty rbs -0.9)


;; ----------- Define Goal -----------
(define (compute_goal)
   (define goal-state
   	(AndLink
			(ListLink
				(AnchorNode "Current State")
				(ConceptNode "A on B")		; my goal state (in this case)
			)
			(VariableNode "$old_states")
		)
	)
	(define vardecl
		(VariableList
			(TypedVariableLink (VariableNode "$old_states") (TypeNode "ListLink"))
		)
	)
   (cog-bc rbs goal-state #:vardecl vardecl)
)

;; ----------- Start Backward Inference -----------
(define result (compute_goal))
(display result)(newline)









