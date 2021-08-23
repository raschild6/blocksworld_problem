(import (opencog ure))
(import (opencog logger))

; import Date Time
(import (srfi :19))

(load "rules_Iterative.scm")

(cog-logger-set-level! (cog-ure-logger) "debug")

; define objects
(InheritanceLink (stv 1 1)
  (ConceptNode "1")
  (ConceptNode "object"))

(EvaluationLink (stv 1 1)
	(PredicateNode "clear")
	(ConceptNode "1"))

(InheritanceLink (stv 1 1)
	(ConceptNode "2")
	(ConceptNode "object"))

(EvaluationLink (stv 1 1)
	(PredicateNode "clear")
	(ConceptNode "2"))
#|
(InheritanceLink (stv 1 1)
	(ConceptNode "3")
	(ConceptNode "object"))

(EvaluationLink (stv 1 1)
	(PredicateNode "clear")
	(ConceptNode "3"))

(InheritanceLink (stv 1 1)
	(ConceptNode "4")
	(ConceptNode "object"))

(InheritanceLink (stv 1 1)
	(ConceptNode "5")
	(ConceptNode "object"))
|#
(NotLink (EqualLink (ConceptNode "1") (ConceptNode "2")))
;(NotLink (EqualLink (ConceptNode "1") (ConceptNode "3")))
;(NotLink (EqualLink (ConceptNode "1") (ConceptNode "4")))
;(NotLink (EqualLink (ConceptNode "2") (ConceptNode "3")))
;(NotLink (EqualLink (ConceptNode "2") (ConceptNode "4")))
;(NotLink (EqualLink (ConceptNode "3") (ConceptNode "4")))


(cog-execute! pickup)
(EvaluationLink
	(PredicateNode "clear")
	(ConceptNode "2"))
(cog-extract! (EvaluationLink
	(PredicateNode "in-hand")
	(ConceptNode "2")))

(cog-execute! stack)
(cog-execute! unstack)
(cog-execute! putdown)
(cog-execute! pickup)
(EvaluationLink
	(PredicateNode "clear")
	(ConceptNode "1"))
(cog-extract! (EvaluationLink
	(PredicateNode "in-hand")
	(ConceptNode "1")))
(cog-execute! stack)
(cog-execute! unstack)
(cog-execute! putdown)
(cog-prt-atomspace)
#|
#|
(define (compute)
   (define goal-state
   	(AndLink
			(ListLink
				(VariableNode "$A")
				(VariableNode "$B")
			)
			;(ListLink
			;	(VariableNode "$B")
			;	(VariableNode "$C")
			;)
			(NotLink (EqualLink (VariableNode "$A") (VariableNode "$B")))
			;(NotLink (EqualLink (VariableNode "$A") (VariableNode "$C")))
			;(NotLink (EqualLink (VariableNode "$B") (VariableNode "$C")))
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
      	;(TypedVariableLink
      	;	(VariableNode "$C")
      	;	(TypeNode "ConceptNode"))
      	;(TypedVariableLink
      	;	(VariableNode "$D")
      	;	(TypeNode "ConceptNode"))
		)
	)
	;(cog-fc rbs init)
   (cog-bc rbs goal-state #:vardecl vardecl)
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


(let ((output-port (open-file "log/result_bc.txt" "a")))
	(display (current-date) output-port)
	(newline output-port)
	(display "----------------------------------" output-port)
	(newline output-port)
	(display result_bc output-port)
	(newline output-port)
  	(close output-port)
)
|#
