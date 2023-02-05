# Card texture depth shader

My quick attempt at recreating the basic "3D" and "Frame Break" effect seen in Marvel Snap.

![effect_sample](./html/effect_sample.gif)

## Overview

This implementation uses (but probably doesn't require) Unity 2022.1. The shader is written in HLSL using the URP (Universal Rendering Pipeline). Everything is done with the following assets in one pass.

- one quad mesh
- a card border texture
- an alpha cutoff texture
- background texture
- midground texture
- title texture

The sample scene includes two cards side-by-side. 

- Left card: "Frame Break" effect
- Right card: "3D" effect

Each card has a separate material where its properties can be modified. The effect can be toggled via a flag on the material inspector. 

## Shader Summary

### Vertex Shader

The background, midground, and title texture each has an associated depth variable. The perceived depth is accomplished by shifting each texture's UV when the card's normal vector points away from the camera view direction. This is done in the vertex shader and output into TEXCOORDX semantic variables for the fragment shader stage.

### Fragment Shader

The final color value is determined by checking whether a texture in front of it exists (alpha isn't zero). I use liberal use of ternary operators to reduce if-else branching. Fortunately, HLSL does not short-circut evaluation and translates this in a single select instruction. 

> Unlike short-circuit evaluation of &&, ||, and ?: in C, HLSL expressions never short-circuit an evaluation because they are vector operations. All sides of the expression are always evaluated.

> Boolean operators function on a per-component basis. This means that if you compare two vectors, the result is a vector containing the Boolean result of the comparison for each component.

https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-operators?redirectedfrom=MSDN#Boolean_Math_Operators

