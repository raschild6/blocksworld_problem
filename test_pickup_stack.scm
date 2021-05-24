(import (opencog ure))
(import (opencog logger))

(load "rules_pickup_stack.scm")

; adjust tv of decontext-1 rule
(cog-set-tv!
	(MemberLink (DefinedSchemaNode "decontext-1") rbs)
	(cog-new-stv 0.5 0.01)
)

(cog-logger-set-level! (cog-ure-logger) "debug")
;(cog-logger-set-stdout! (cog-ure-logger) #t)

(define init
	(SetLink
		; define objects
		(EvaluationLink (stv 1 1)
			(PredicateNode "free")
			(ConceptNode "hand"))

		(InheritanceLink (stv 1 1)
		  (ConceptNode "1")
		  (ConceptNode "object"))
		(EvaluationLink (stv 1 1)
			(PredicateNode "on-table")
			(ConceptNode "1"))
		(EvaluationLink (stv 1 1)
			(PredicateNode "clear")
			(ConceptNode "1"))

		(InheritanceLink (stv 1 1)
			(ConceptNode "2")
			(ConceptNode "object"))
		(EvaluationLink (stv 1 1)
			(PredicateNode "on-table")
			(ConceptNode "2"))
		(EvaluationLink (stv 1 1)
			(PredicateNode "clear")
			(ConceptNode "2"))

		(InheritanceLink (stv 1 1)
			(ConceptNode "3")
			(ConceptNode "object"))
		(EvaluationLink (stv 1 1)
			(PredicateNode "on-table")
			(ConceptNode "3"))
		(EvaluationLink (stv 1 1)
			(PredicateNode "clear")
			(ConceptNode "3"))

		(InheritanceLink (stv 1 1)
			(ConceptNode "4")
			(ConceptNode "object"))
		(EvaluationLink (stv 1 1)
			(PredicateNode "on-table")
			(ConceptNode "4"))
		(EvaluationLink (stv 1 1)
			(PredicateNode "clear")
			(ConceptNode "4"))

		(InheritanceLink (stv 1 1)
			(ConceptNode "5")
			(ConceptNode "object"))
		(EvaluationLink (stv 1 1)
			(PredicateNode "on-table")
			(ConceptNode "5"))
		(EvaluationLink (stv 1 1)
			(PredicateNode "clear")
			(ConceptNode "5"))

		(NotLink (EqualLink (ConceptNode "1") (ConceptNode "2")))
		(NotLink (EqualLink (ConceptNode "1") (ConceptNode "3")))
		(NotLink (EqualLink (ConceptNode "1") (ConceptNode "4")))
		(NotLink (EqualLink (ConceptNode "1") (ConceptNode "5")))
		(NotLink (EqualLink (ConceptNode "2") (ConceptNode "3")))
		(NotLink (EqualLink (ConceptNode "2") (ConceptNode "4")))
		(NotLink (EqualLink (ConceptNode "2") (ConceptNode "5")))
		(NotLink (EqualLink (ConceptNode "3") (ConceptNode "4")))
		(NotLink (EqualLink (ConceptNode "3") (ConceptNode "5")))
		(NotLink (EqualLink (ConceptNode "4") (ConceptNode "5")))
	)
)

(define (compute)
   (define goal
   	(AndLink
   		(EvaluationLink
				(PredicateNode "on")
				(ListLink
					(VariableNode "$D")
					(VariableNode "$C")))
			(EvaluationLink
				(PredicateNode "on")
				(ListLink
					(VariableNode "$C")
					(VariableNode "$B")))
			(EvaluationLink
				(PredicateNode "on")
				(ListLink
					(VariableNode "$B")
					(VariableNode "$A")))
			(NotLink (EqualLink (VariableNode "$A") (VariableNode "$B")))
			(NotLink (EqualLink (VariableNode "$A") (VariableNode "$C")))
			(NotLink (EqualLink (VariableNode "$A") (VariableNode "$D")))
			(NotLink (EqualLink (VariableNode "$B") (VariableNode "$C")))
			(NotLink (EqualLink (VariableNode "$B") (VariableNode "$D")))
			(NotLink (EqualLink (VariableNode "$C") (VariableNode "$D")))
		)
	)
	(define vardecl
  		(VariableList
    		(TypedVariableLink
      		(VariableNode "$A")
      		(TypeNode "ConceptNode"))
    		(TypedVariableLink
				(VariableNode "$B")
				(TypeNode "ConceptNode"))
			(TypedVariableLink
				(VariableNode "$C")
				(TypeNode "ConceptNode"))
			(TypedVariableLink
				(VariableNode "$D")
				(TypeNode "ConceptNode"))
		)
	)
	;(cog-fc rbs init)
   (cog-bc rbs goal #:vardecl vardecl)
)

(define rbs (ConceptNode "block-world"))
(ure-set-maximum-iterations rbs 100)
; positive: breadth first - negative: depth first - 0: neutral
(ure-set-complexity-penalty rbs -0.9)
; maximum number of inference trees the BIT can hold. Negative(default): unlimited.
;(ure-set-bc-maximum-bit-size rbs 10)

; Find all the (probabilistic) Dispositions of
; the given number of blocks required by the goal (= # letters used)
; on the total number of blocks in the knowledge-base (= highest number used)
; (i.e. A on B, B on C of 5 total blocks = 5D3 = 60 different config)
(define result (compute))
(display result)(newline)

