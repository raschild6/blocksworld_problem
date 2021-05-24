(use-modules (opencog) (opencog ure) (opencog exec) (opencog pln) (opencog logger))

(define (action_generic . args)
	(let
		((tmp (car args)))
		tmp
	)
)

(define pickup-action action_generic)
(define stack-action action_generic)
(define goal-to-stack-action action_generic)


(define pickup 
	(BindLink
   	(VariableList
	   	(TypedVariableLink
	   		(VariableNode "?ob") (TypeNode "ConceptNode"))
	   ) ; parameters
		(PresentLink
			(InheritanceLink
				(VariableNode "?ob")
				(ConceptNode "object"))
			(ContextLink
				(AndLink
					(EvaluationLink
						(PredicateNode "clear")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "on-table")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "free")
						(VariableNode "hand"))
				)
			)
		)
		(ExecutionOutputLink
			(GroundedSchemaNode "scm: pickup-action")
			(ListLink
				(ContextLink ; effect
					(AndLink
						(EvaluationLink
							(PredicateNode "holding")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "not-clear")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "not-on-table")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "not-free")
							(ConceptNode "hand"))
					)
				)
				(ContextLink ; precondition
					(AndLink
						(EvaluationLink
							(PredicateNode "clear")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "on-table")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "free")
							(VariableNode "hand"))
					)
				)
			)
	   )
	)
)


(define stack
	(BindLink
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
			(ContextLink
				(AndLink
					(EvaluationLink
						(PredicateNode "holding")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "not-clear")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "not-on-table")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "not-free")
						(ConceptNode "hand"))
					(EvaluationLink
						(PredicateNode "clear")
						(VariableNode  "?underob"))
				)
			)
		)
		(ExecutionOutputLink
			(GroundedSchemaNode "scm: stack-action")
			(ListLink
				(ContextLink ; effect
					(AndLink
						(EvaluationLink
							(PredicateNode "clear")
							(VariableNode  "?ob"))
						(EvaluationLink
							(PredicateNode "on")
							(ListLink
								(VariableNode "?ob")
								(VariableNode "?underob")))
						(EvaluationLink
							(PredicateNode "not-clear")
							(VariableNode "?underob"))
						(EvaluationLink
							(PredicateNode "not-holding")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "free")
							(ConceptNode "hand"))
					)
				)
				(ContextLink
					(AndLink ; preconditon (= pickup + clear_underob)
						(EvaluationLink
							(PredicateNode "holding")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "not-clear")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "not-on-table")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "not-free")
							(ConceptNode "hand"))
						(EvaluationLink
							(PredicateNode "clear")
							(VariableNode  "?underob"))
					)
				)
			)
		)
	)
)

(define add-one-to-context
	(BindLink
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
			(ContextLink
				(AndLink
					(EvaluationLink
						(PredicateNode "holding")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "not-clear")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "not-on-table")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "not-free")
						(ConceptNode "hand"))
				)
			)
   	)
		(ExecutionOutputLink
			(GroundedSchemaNode "scm: dummy_add_context")
			(ListLink
				(ContextLink ; effect
					(AndLink
						(EvaluationLink
							(PredicateNode "holding")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "not-clear")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "not-on-table")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "not-free")
							(ConceptNode "hand"))
						(EvaluationLink
							(PredicateNode "clear")
							(VariableNode  "?underob"))
					)
				)
				(ContextLink
					(AndLink
						(EvaluationLink
							(PredicateNode "holding")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "not-clear")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "not-on-table")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "not-free")
							(ConceptNode "hand"))
					)
				)
			)
	   )
	)
)

(define goal-to-stack
	(BindLink
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
			(ContextLink ; precondition
				(AndLink
					(EvaluationLink
						(PredicateNode "clear")
						(VariableNode  "?ob"))
					(EvaluationLink
						(PredicateNode "on")
						(ListLink
							(VariableNode "?ob")
							(VariableNode "?underob")))
					(EvaluationLink
						(PredicateNode "not-clear")
						(VariableNode "?underob"))
					(EvaluationLink
						(PredicateNode "not-holding")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "free")
						(ConceptNode "hand"))
				)
			)
		)
		(ExecutionOutputLink
			(GroundedSchemaNode "scm: goal-to-stack-action")
			(ListLink
				(EvaluationLink ; effect
					(PredicateNode "on")
					(ListLink
						(VariableNode "?ob")
						(VariableNode "?underob")))
				(ContextLink ; precondition
					(AndLink
						(EvaluationLink
							(PredicateNode "clear")
							(VariableNode  "?ob"))
						(EvaluationLink
							(PredicateNode "on")
							(ListLink
								(VariableNode "?ob")
								(VariableNode "?underob")))
						(EvaluationLink
							(PredicateNode "not-clear")
							(VariableNode "?underob"))
						(EvaluationLink
							(PredicateNode "not-holding")
							(VariableNode "?ob"))
						(EvaluationLink
							(PredicateNode "free")
							(ConceptNode "hand"))
					)
				)
			)
	   )
	)
)


(define (add-to-rule-base bindlink name rbs)
	(DefineLink
   	(DefinedSchemaNode name)
      bindlink)
   (MemberLink (stv 1 0.01)
   	(DefinedSchemaNode name)
   	rbs)
)



;;;;;;;;;;;;;;;;
;; Load rules ;;
;;;;;;;;;;;;;;;;

(define rbs (ConceptNode "block-world"))


;; noskill base-rules:

		(define (dummy . args)
			(let
				((tmp (car args)))
				;(display "dummy-intro: ")(newline)
				;(display tmp)(newline)
				tmp
			)
		)

		(define (dummy_context . args)
			(let
				((tmp (car args)))
				;(display "dummy-intro: ")(newline)
				;(display tmp)(newline)
				tmp
			)
		)

		(define (dummy_add_context . args)
			(let
				((tmp (car args)))
				;(display "dummy-intro: ")(newline)
				;(display tmp)(newline)
				tmp
			)
		)

		;; Generate a list of variables (Variable prefix + "-" + to_string(n))
		(define (gen-variables prefix n)
			(if (= n 0)
				;; Base case
				'()
				;; Recursive case
				(append (gen-variables prefix (- n 1))
						  (list (gen-variable prefix (- n 1)))
				)
			)
		)

		(define (lastElem list) (car (reverse list)))

		;; Generate a fuzzy conjunction elemination rule for an n-ary
		;; conjunction
		(define (gen-conjunction-elemination-rule nary)
			(let* ((variables (gen-variables "$X" nary))
					(EvaluationT (Type "EvaluationLink"))
					(InheritanceT (Type "InheritanceLink"))
					(type (TypeChoice EvaluationT InheritanceT))
					(gen-typed-variable (lambda (x) (TypedVariable x type)))
					(vardecl (VariableList (map gen-typed-variable variables)))
					(pattern (AndLink variables))
					(rewrite (ExecutionOutput
								  (GroundedSchema "scm: dummy")
								  ;; We wrap the variables in Set because the order
								  ;; doesn't matter and that way alpha-conversion
								  ;; works better.
								  (List (car variables) (And variables)))))
				(Bind
					vardecl
					pattern
					rewrite
				)
			)
		)


		;; Generate a fuzzy conjunction introduction rule for an n-ary
		;; conjunction
		(define (gen-conjunction-introduction-rule nary)
			(let* ((variables (gen-variables "$X" nary))
					(EvaluationT (Type "EvaluationLink"))
					(InheritanceT (Type "InheritanceLink"))
					(ContextT (Type "ContextLink"))
					(AndT (Type "AndLink"))
					(NotT (Type "NotLink"))
					(type (TypeChoice EvaluationT InheritanceT ContextT AndT NotT))
					(gen-typed-variable (lambda (x) (TypedVariable x type)))
					(vardecl (VariableList (map gen-typed-variable variables)))
					(pattern (PresentLink variables))
					(rewrite (ExecutionOutput
								  (GroundedSchema "scm: dummy")
								  ;; We wrap the variables in Set because the order
								  ;; doesn't matter and that way alpha-conversion
								  ;; works better.
								  (List (And variables) (Set variables)))))
					(Bind
						vardecl
						pattern
						rewrite
					)
			)
		)

		;; Contextualize an AndLink (in fc, decontext in bc)
		; (And (..))
		; ->
		; (Context (And (..))
		; FIXME: useless type-mapping
		(define (gen-contextualize-evaluation-rule nary)
			(let* ((variables (gen-variables "$X" nary))
					(AndT (Type "AndLink"))
					(type (TypeChoice AndT))
					(gen-typed-variable (lambda (x) (TypedVariable x type)))
					(vardecl (VariableList (map gen-typed-variable variables)))
					(pattern (PresentLink variables))
					(rewrite (ExecutionOutput
								  (GroundedSchema "scm: dummy_context")
								  ;; We wrap the variables in Set because the order
								  ;; doesn't matter and that way alpha-conversion
								  ;; works better.
								  (List (Context variables) (Set variables)))))
					(Bind
						vardecl
						pattern
						rewrite
					)
			)
		)

		;; Add an Extra_Atom to a ContextLink
		; (Context (And (..))
		; ->
		; (Context (And ((Extra_Atom,..))
		; FIXME: useless type-mapping
		(define (gen-contextualize-evaluation-rule nary)
			(let* ((variables (gen-variables "$X" nary))
					(AndT (Type "AndLink"))
					(type (TypeChoice AndT))
					(gen-typed-variable (lambda (x) (TypedVariable x type)))
					(vardecl (VariableList (map gen-typed-variable variables)))
					(pattern (PresentLink variables))
					(rewrite (ExecutionOutput
								  (GroundedSchema "scm: dummy_context")
								  ;; We wrap the variables in Set because the order
								  ;; doesn't matter and that way alpha-conversion
								  ;; works better.
								  (List (Context variables) (Set variables)))))
					(Bind
						vardecl
						pattern
						rewrite
					)
			)
		)


		(define (replace_in_bind bindlink arguments)
			  (substitute-var (get-bindings bindlink arguments) bindlink))

		;(add-to-rule-base (gen-conjunction-introduction-rule 1) "conj-1" rbs)
		;(add-to-rule-base (gen-conjunction-introduction-rule 2) "conj-2" rbs)
		(add-to-rule-base (gen-conjunction-introduction-rule 3) "conj-3" rbs)
		;(add-to-rule-base (gen-conjunction-introduction-rule 4) "conj-4" rbs)
		;(add-to-rule-base (gen-conjunction-introduction-rule 5) "conj-5" rbs)
		;(add-to-rule-base (gen-conjunction-introduction-rule 6) "conj-6" rbs)
		;(add-to-rule-base (gen-conjunction-introduction-rule 7) "conj-7" rbs)
		;(add-to-rule-base (gen-conjunction-introduction-rule 8) "conj-8" rbs)
		(add-to-rule-base (gen-conjunction-introduction-rule 9) "conj-9" rbs)
		;(add-to-rule-base (gen-conjunction-introduction-rule 10) "conj-10" rbs)
		;(add-to-rule-base (gen-conjunction-introduction-rule 11) "conj-11" rbs)
		;(add-to-rule-base (gen-conjunction-introduction-rule 12) "conj-12" rbs)

		;(add-to-rule-base (gen-conjunction-elemination-rule 1) "conj-elem-1" rbs)
		;(add-to-rule-base (gen-conjunction-elemination-rule 2) "conj-elem-2" rbs)
		;(add-to-rule-base (gen-conjunction-elemination-rule 3) "conj-elem-3" rbs)
		;(add-to-rule-base (gen-conjunction-elemination-rule 4) "conj-elem-4" rbs)
		;(add-to-rule-base (gen-conjunction-elemination-rule 5) "conj-elem-5" rbs)
		;(add-to-rule-base (gen-conjunction-elemination-rule 6) "conj-elem-6" rbs)
		;(add-to-rule-base (gen-conjunction-elemination-rule 7) "conj-elem-7" rbs)
		;(add-to-rule-base (gen-conjunction-elemination-rule 8) "conj-elem-8" rbs)
		;(add-to-rule-base (gen-conjunction-elemination-rule 9) "conj-elem-9" rbs)
		;(add-to-rule-base (gen-conjunction-elemination-rule 10) "conj-elem-10" rbs)
		;(add-to-rule-base (gen-conjunction-elemination-rule 11) "conj-elem-11" rbs)
		;(add-to-rule-base (gen-conjunction-elemination-rule 12) "conj-elem-12" rbs)

(add-to-rule-base pickup "pickup" rbs)
(add-to-rule-base stack "stack" rbs)
(add-to-rule-base add-one-to-context "add-one-to-context" rbs)
(add-to-rule-base goal-to-stack "goal-to-stack" rbs)
(add-to-rule-base (gen-contextualize-evaluation-rule 1) "decontext-1" rbs)
