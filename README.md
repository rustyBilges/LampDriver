# LampDriver
Processing driver code for IJP's gnarly 3D-printed lamps (using OPC library).

Lamps are represented on-screen. The beahviour of the on-screen lamps should be the same as the real-worl lamps. 

Users can select from 5 different modes for contorolling the lamps:

* 1: Unmapped
* 2: Stochastic
* 3: Alternate
* 4: Unmapped fast
* 5: Channels

The code is functional. There is a null pointer exception from the modeSelect radioButton controller (bp6). This throws an error whenever a new mode is selected but it does not break the programme. I haven't had time to debug and fix yet.

The code was written at high speed so is pretyy messy and could do with some refactoring and cleaning up!
