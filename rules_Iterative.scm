(use-modules (opencog) (opencog ure) (opencog exec) (opencog pln) (opencog logger))

; import Date Time
(import (srfi :19))

(define (action_pickup . args)
	(define precond (car (cdr args)))
	(define effect (car args))
	(cog-extract-recursive! precond)
	effect
)
(define (action_putdown . args)
	(define precond (car (cdr args)))
	(define effect (car args))
	(cog-extract-recursive! precond)
	effect
)
(define (action_stack . args)
	(define precond (car (cdr args)))
	(define effect (car args))
	; over_obj = get the (VariableNode "?ob")
	(define over_obj (cog-outgoing-atom (cog-outgoing-atom effect 1) 0))
	; under_obj = get the (VariableNode "?underob")
	(define under_obj (cog-outgoing-atom (cog-outgoing-atom effect 1) 1))

	; remove precondition because it doesn't hold anymore
	(cog-extract-recursive! precond)
	(cog-extract! (Predicate "in-hand"))

	; remove under_obj clear
	(cog-extract! (Evaluation (Predicate "clear") under_obj))
	(cog-extract! (Predicate "clear"))

	; apply over_obj clear
	(EvaluationLink (PredicateNode "clear") over_obj)

	; finally, apply effect
	effect
)
(define (action_unstack . args)
	(define precond (car (cdr args)))
	(define effect (car args))
	; over_obj = get the (VariableNode "?ob")
	(define over_obj (cog-outgoing-atom (cog-outgoing-atom precond 1) 0))
	; under_obj = get the (VariableNode "?underob")
	(define under_obj (cog-outgoing-atom (cog-outgoing-atom precond 1) 1))

	; remove precondition because it doesn't hold anymore
	(cog-extract-recursive! precond)
	(cog-extract! (Predicate "on"))
	(cog-extract! (List over_obj under_obj))

	; remove over_obj clear
	(cog-extract! (Evaluation (Predicate "clear") over_obj))
	(cog-extract! (Predicate "clear"))

	; apply under_obj clear
	(EvaluationLink (PredicateNode "clear") under_obj)

	; finally, apply effect
	effect
)
(define pickup-action action_pickup)
(define putdown-action action_putdown)
(define stack-action action_stack)
(define unstack-action action_unstack)


(define stack
	(QueryLink
   	(VariableList
	   	(TypedVariableLink (VariableNode "?ob") (TypeNode "ConceptNode"))
	   	(TypedVariableLink (VariableNode "?underob") (TypeNode "ConceptNode"))
	   ) ; parameters
		(PresentLink
			(NotLink
				(EqualLink (VariableNode "?ob") (VariableNode "?underob")))
			(InheritanceLink
				(VariableNode "?ob")
				(ConceptNode "object"))
			(InheritanceLink
				(VariableNode "?underob")
				(ConceptNode "object"))
			(EvaluationLink
				(PredicateNode "in-hand")
				(VariableNode "?ob"))
			(EvaluationLink
				(PredicateNode "clear")
				(VariableNode "?underob"))
		)
		(ExecutionOutputLink
			(GroundedSchemaNode "scm: stack-action")
			(ListLink
				; effect
				(EvaluationLink
					(PredicateNode "on")
					(ListLink
						(VariableNode "?ob")
						(VariableNode "?underob")
					)
				)
				; precondition
				(EvaluationLink
					(PredicateNode "in-hand")
					(VariableNode "?ob"))
			)
	   )
	)
)


(define unstack
	(QueryLink
   	(VariableList
	   	(TypedVariableLink (VariableNode "?ob") (TypeNode "ConceptNode"))
	   	(TypedVariableLink (VariableNode "?underob") (TypeNode "ConceptNode"))
	   ) ; parameters
		(PresentLink
			(NotLink
				(EqualLink (VariableNode "?ob") (VariableNode "?underob")))
			(InheritanceLink
				(VariableNode "?ob")
				(ConceptNode "object"))
			(InheritanceLink
				(VariableNode "?underob")
				(ConceptNode "object"))
			(EvaluationLink
				(PredicateNode "on")
				(ListLink
					(VariableNode "?ob")
					(VariableNode "?underob")
				)
			)
		)
		(ExecutionOutputLink
			(GroundedSchemaNode "scm: unstack-action")
			(ListLink
				; effect
				(EvaluationLink
					(PredicateNode "in-hand")
					(VariableNode "?ob"))
				; precondition
				(EvaluationLink
					(PredicateNode "on")
					(ListLink
						(VariableNode "?ob")
						(VariableNode "?underob")
					)
				)
			)
	   )
	)
)


(define putdown
	(QueryLink
   	(VariableList
	   	(TypedVariableLink
	   		(VariableNode "?ob") (TypeNode "ConceptNode"))
	   ) ; parameters
		(PresentLink
			(InheritanceLink
				(VariableNode "?ob")
				(ConceptNode "object"))
			(EvaluationLink
				(PredicateNode "in-hand")
				(VariableNode "?ob"))
		)
		(ExecutionOutputLink
			(GroundedSchemaNode "scm: putdown-action")
			(ListLink
				; effect
				(EvaluationLink
					(PredicateNode "clear")
					(VariableNode "?ob")
				)
				; precondition
				(EvaluationLink
					(PredicateNode "in-hand")
					(VariableNode "?ob")
				)
			)
	   )
	)
)


(define pickup
	(QueryLink
   	(VariableList
	   	(TypedVariableLink
	   		(VariableNode "?ob") (TypeNode "ConceptNode"))
	   ) ; parameters
		(PresentLink
			(InheritanceLink
				(VariableNode "?ob")
				(ConceptNode "object"))
			(EvaluationLink
				(PredicateNode "clear")
				(VariableNode "?ob"))
		)
		(ExecutionOutputLink
			(GroundedSchemaNode "scm: pickup-action")
			(ListLink
				; effect
				(EvaluationLink
					(PredicateNode "in-hand")
					(VariableNode "?ob"))
				; precondition
				(EvaluationLink
					(PredicateNode "clear")
					(VariableNode "?ob"))
			)
	   )
	)
)


;;;;;;;;;;;;;;;;
;; Load rules ;;
;;;;;;;;;;;;;;;;

(define (conjunction . args)
	(let
		((tmp (car args)))
		tmp
	)
)

(define (gen-conjunction-introduction-rule nary)
	(let* ((variables (gen-variables "$X" nary))
			(EvalT (Type "EvaluationLink"))
			(ContextT (Type "ContextLink"))
			(ListT (Type "ListLink"))
			(NotT (Type "NotLink"))
			(type (TypeChoice EvalT ListT NotT ContextT))
			(gen-typed-variable (lambda (x) (TypedVariable x type)))
			(vardecl (VariableList (map gen-typed-variable variables)))
			(pattern (PresentLink variables))
			(rewrite (ExecutionOutput
						  (GroundedSchema "scm: conjunction")
						  ;; We wrap the variables in Set because the order
						  ;; doesn't matter and that way alpha-conversion
						  ;; works better.
						  (List
						  		(And variables)
						  		(Set variables)
						  ))
			))
			(Query
				vardecl
				pattern
				rewrite
			)
	)
)


(define rbs (ConceptNode "block-world"))

(define (add-to-rule-base QueryLink name rbs)
	(DefineLink
   	(DefinedSchemaNode name)
      QueryLink)
   (MemberLink (stv 1 0.01)
   	(DefinedSchemaNode name)
   	rbs)
)


;(add-to-rule-base (gen-conjunction-introduction-rule 2) "conj-2" rbs)
;(add-to-rule-base (gen-conjunction-introduction-rule 5) "conj-5" rbs)

(add-to-rule-base pickup "pickup" rbs)
(add-to-rule-base stack "stack" rbs)
(add-to-rule-base unstack "unstack" rbs)
(add-to-rule-base putdown "putdown" rbs)