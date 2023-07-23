# UART

This is a UART design in Verilog HDL. The designed UART works in simplex mode or can be configured to work as a Tx/Rx only using conditional compilation through defines.v.

Alternatively, you can access the project through this EDA Playground [link](https://edaplayground.com/x/9NMt).

## Working

The UART is a digital circuit that sends parallel data through a serial line asynchronously, which means there is no Clock signal to synchronize the output bits from the transmitting UART to the Sampling of bits by the receiving UART. It can work in simplex, half duplex or full duplex mode.

![image](https://github.com/theHDLguy/UART/assets/76950564/04e83457-730b-4e0f-bc48-00cd8b36d8a2)

## UART Data Packet
Each UART Packet Contains 1 START bit, 5 to 8 DATA bits (depending on the UART), an optional PARITY bit and 1 or 2 STOP bits. In this project, I have used 1 start bit, 8 data bits and 1 stop bit.

![image](https://github.com/theHDLguy/UART/assets/76950564/30413dc5-b6b2-4a01-8a13-99fed45b71c3)

## TX FSM

![image](https://github.com/theHDLguy/UART/assets/76950564/7dac2229-9d38-4367-af0c-10d9f3f0ddb7)

## RX FSM

![image](https://github.com/theHDLguy/UART/assets/76950564/6fe1daf8-2f6b-4e46-b4f1-e0ce1695c929)


## Output
This is the output of the UART testbench in simplex mode:

![image](https://github.com/theHDLguy/UART/assets/76950564/11fe7123-b30e-4436-9265-6727f85ac0e9)

## Waveform
![image](https://github.com/theHDLguy/UART/assets/76950564/e7ce3b6a-b530-4865-b6c2-9b7b05e5fcc0)

### Zoomed in:

![image](https://github.com/theHDLguy/UART/assets/76950564/7aa772ec-467b-4143-89e7-560d4f803415)

## Schematics

![image](https://github.com/theHDLguy/UART/assets/76950564/66fdace2-30d7-4f09-8796-fdde05567d02)
