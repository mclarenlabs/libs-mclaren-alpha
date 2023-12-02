"
  List the variables in the scriptingEnvironment.
  Also demonstrate adding and removing a name.
"

[|

  main
    Foo := 'thing'.
    env := Application scriptingEnvironment.

    Transcript showLine:('Env ', env description).
    Transcript showLine:('Env names', env knownObjectNames description).

    Transcript showLine:('==== Removing Foo ===').
    env removeObjectWithName:'Foo'.
    Transcript showLine:('Env names', env knownObjectNames description).
] 
