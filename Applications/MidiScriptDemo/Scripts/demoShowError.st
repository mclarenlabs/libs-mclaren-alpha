"
  Try to open a non-existent device and display an alert.
  This uses the Transcript showError to display the error.
"

[| :noglobals


main
  | errp |

  "Open a sequencer"
  errp := NSErrorPtr new.
  seq := ASKSeq alloc initWithError:errp.

  Transcript showLine:('seq: ', seq description).

  errp hasValue
    ifTrue: [
      Transcript showError:('Sequencer cannot be opened: ', (errp err) description).
    ].

  "Try to find non-existent device"
  notfound := seq parseAddress:'NONEXISTENTTHING' error:errp.

  Transcript showLine:('notfound: ', notfound description).
  Transcript showLine:('errp: ', errp description).

  errp hasValue
    ifTrue: [
      Transcript showError:('Cannot find SEQ device: ', (errp err) description).
      self exit.
      Transcript showError:('Will not get to this line').
    ].

  Transcript showLine:('Fini').

]
