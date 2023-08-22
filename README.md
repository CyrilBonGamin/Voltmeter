# Voltmeter software for Atmega8
Assembly language code for a voltmeter that is based on a microcontroller Atmega8.
Able to work with sinusoidal and triangular voltage.

Circuit diagram for testing
![](https://github.com/CyrilBonGamin/Voltmeter/blob/master/circuit.png)

## Test results
Input alternating sinusoidal voltage with a frequency of 60 Hz and an amplitude of 100V.
![](https://github.com/CyrilBonGamin/Voltmeter/blob/master/voltage%20sin.png)

Result of the device

![](https://github.com/CyrilBonGamin/Voltmeter/blob/master/result%20sin.png)

Formula calculation

![](https://github.com/CyrilBonGamin/Voltmeter/blob/master/formula%20sin.png)

Input alternating triangular voltage with a frequency of 60 Hz and an amplitude of 50V.
![](https://github.com/CyrilBonGamin/Voltmeter/blob/master/voltage.png)

Result of the device

![](https://github.com/CyrilBonGamin/Voltmeter/blob/master/result.png)

Formula calculation

![](https://github.com/CyrilBonGamin/Voltmeter/blob/master/formula.png)

The error is explained by the imperfect discreteness of the ADC, approximations in the program.

