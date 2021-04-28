; import Date Time
(import (srfi :19))

(use-modules (opencog logger) (opencog ure))

(load "rules.scm")


(cog-logger-set-level! (cog-ure-logger) "fine")
;(cog-logger-set-filename! (cog-ure-logger) "log/ure.log")
; Redirect the log to stdout
(cog-logger-set-stdout! (cog-ure-logger) #t)

(define rbs (ConceptNode "block-world"))

;; Init Knowledge Base
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
#|
		(InheritanceLink (stv 1 1)
			(ConceptNode "3")
			(ConceptNode "object"))
		(EvaluationLink (stv 1 1)
			(PredicateNode "on-table")
			(ConceptNode "3"))
		(EvaluationLink (stv 1 1)
			(PredicateNode "clear")
			(ConceptNode "3"))
|#
	)
)



;; Backward Chaining
(define (return_bc)
	(define goal
		(AndLink
			(EvaluationLink
				(PredicateNode "on")
				(ListLink
					(VariableNode "$A")
					(VariableNode "$B"))
			)
#|			(EvaluationLink
				(PredicateNode "on")
				(ListLink
					(VariableNode "$B")
					(VariableNode "$C"))
			)
			(NotLink
				(EqualLink (VariableNode "$A") (VariableNode "$B")))
			(NotLink
				(EqualLink (VariableNode "$B") (VariableNode "$C")))
			(NotLink
				(EqualLink (VariableNode "$A") (VariableNode "$C")))
|#
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
#|			(TypedVariableLink
				(VariableNode "$C")
				(TypeNode "ConceptNode"))
|#
		)
	)

	;(display goal)
	(cog-bc rbs goal #:vardecl vardecl #:maximum-iterations 200)
)

(define result_bc (return_bc))

; Display result in shell or..
(display "Result BC: ")(newline)
(display result_bc)

;..Redirect result_bc output to a file
#|
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
