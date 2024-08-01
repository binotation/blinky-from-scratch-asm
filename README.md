# Blinky From Scratch ARM Assembly
Implement blinky in ARM assembly. Some minimal runtime is still needed:
- Stack (not used in this program)
- PC-relative loads from literal pool

`TIM2_IRQHandler` needs to be declared as a function symbol otherwise we get a hard fault.
