


.IFNDEF LOG10
.EQU LOG10,1

.INCLUDE "math/expressions/log/log_e.s"
// double log10(double {x}, double {tolerance})//
//	Computes Taylor Series approximation of log10({x}) to
//	within tolerance {tolerance}/ln(10), returning in {x}.
// if x<=0, return NaN
// otherwise bisect thru lookup table for a matched power of 10
// otherwise compute via log_e(x)
// @param x [d0] — value to compute log10 of
// @param tolerance [d1] — approximation tolerance (relative to ln(10))
// @return [d0] — log10(x), or NaN if x <= 0
log10:
    stp x29, x30, [sp, #-16]!
    str d2, [sp, #-16]!
    stp x0, x1, [sp, #-16]!
    str d3, [sp, #-16]!
    stp x2, x3, [sp, #-16]!
    mov x29, sp 

    //if x<=0 return NaN
    adr x0, lookup_table
    ldr d1, [x1]
    fcmp d0, d1
    b.le .ret_NaN_log_10

    mov x0, #0 //range lower bound 0
    mov x4, #634 //range upper bound

.bisection_loop:
    mov x2, x0 //pegando a lower bound
    add x2, x2, x1 // add upper bound
    lsr x2, x2, #1 // x2 / 2 
    cmp x2, x0
    b.eq .converged
    adr x1, lookup_table
    ldr d3, [x1, lsl x0, x0, #3] //offset = x0*8
    fcmp d0, d3
    b.gt .shrink_up
    b.lt .shrink_down

.converged:
    //justo 2 options
    adr x1, lookup_table
    ldr d3, [x1, lsl x0, x0, #3] //offset = x0*8
    fcmp d0, d3
    b.ne .not_x0
    sub x0, x0, #324
    scvtf d0, x0
    b .leave_pre_cond_log10

.not_x0:
    adr x1, lookup_table
    ldr d3, [x1, lsl x0, x0, #3] //offset = x0*8
    fcmp d0, d3
    b.ne .not_found_log10
    sub x0, x0, #324
    scvtf d0, x0
    b .leave_pre_cond_log10

.shrink_up:
    mov x0, x2
    b .bisection_loop

.shrink_down:
    mov x4, x2
    b .bisection_loop

.not_found_log10:
    bl log_e
    adr x1, ln_ten_inv
    ldr d2, [x1]
    fmul d0, d0, d2 //{d0}=ln(d0)/ln(10)
    b .leave_pre_cond_log10

.ret_NaN_log_10:
    adr x1, NaN
    ldr d0, [x1]
    b .leave_pre_cond_log10


.leave_pre_cond_log10:
    mov sp, x29 
    ldp x2, x3, [sp], #16
    ldr d3, [sp], #16
    ldp x0, x1, [sp], #16
    ldr d2, [sp], #16
    ldp x29, x30, [sp], #16
    ret

ln_ten_inv:
    .quad 0x3fdbcb7b1526e50d //1/ln(10)


NaN:
	.quad 0x7FF0000000000001

lookup_table:
	.quad 0x0000000000000000//1e-324 (actually returns NaN, handled above)
	.quad 0x0000000000000002//1e-323
	.quad 0x0000000000000014//1e-322
	.quad 0x00000000000000ca//1e-321
	.quad 0x00000000000007e8//1e-320
	.quad 0x0000000000004f10//1e-319
	.quad 0x00000000000316a2//1e-318
	.quad 0x00000000001ee257//1e-317
	.quad 0x000000000134d761//1e-316
	.quad 0x000000000c1069cd//1e-315
	.quad 0x0000000078a42205//1e-314
	.quad 0x00000004b6695433//1e-313
	.quad 0x0000002f201d49fb//1e-312
	.quad 0x000001d74124e3d1//1e-311
	.quad 0x000012688b70e62b//1e-310
	.quad 0x0000b8157268fdaf//1e-309
	.quad 0x000730d67819e8d2//1e-308
	.quad 0x0031fa182c40c60d//1e-307
	.quad 0x0066789e3750f791//1e-306
	.quad 0x009c16c5c5253575//1e-305
	.quad 0x00d18e3b9b374169//1e-304
	.quad 0x0105f1ca820511c3//1e-303
	.quad 0x013b6e3d22865634//1e-302
	.quad 0x017124e63593f5e1//1e-301
	.quad 0x01a56e1fc2f8f359//1e-300
	.quad 0x01dac9a7b3b7302f//1e-299
	.quad 0x0210be08d0527e1d//1e-298
	.quad 0x0244ed8b04671da5//1e-297
	.quad 0x027a28edc580e50e//1e-296
	.quad 0x02b059949b708f29//1e-295
	.quad 0x02e46ff9c24cb2f3//1e-294
	.quad 0x03198bf832dfdfb0//1e-293
	.quad 0x034feef63f97d79c//1e-292
	.quad 0x0383f559e7bee6c1//1e-291
	.quad 0x03b8f2b061aea072//1e-290
	.quad 0x03ef2f5c7a1a488e//1e-289
	.quad 0x04237d99cc506d59//1e-288
	.quad 0x04585d003f6488af//1e-287
	.quad 0x048e74404f3daadb//1e-286
	.quad 0x04c308a831868ac9//1e-285
	.quad 0x04f7cad23de82d7b//1e-284
	.quad 0x052dbd86cd6238d9//1e-283
	.quad 0x05629674405d6388//1e-282
	.quad 0x05973c115074bc6a//1e-281
	.quad 0x05cd0b15a491eb84//1e-280
	.quad 0x060226ed86db3333//1e-279
	.quad 0x0636b0a8e891ffff//1e-278
	.quad 0x066c5cd322b67fff//1e-277
	.quad 0x06a1ba03f5b21000//1e-276
	.quad 0x06d62884f31e93ff//1e-275
	.quad 0x070bb2a62fe638ff//1e-274
	.quad 0x07414fa7ddefe3a0//1e-273
	.quad 0x0775a391d56bdc87//1e-272
	.quad 0x07ab0c764ac6d3a9//1e-271
	.quad 0x07e0e7c9eebc444a//1e-270
	.quad 0x081521bc6a6b555c//1e-269
	.quad 0x084a6a2b85062ab3//1e-268
	.quad 0x0880825b3323dab0//1e-267
	.quad 0x08b4a2f1ffecd15c//1e-266
	.quad 0x08e9cbae7fe805b3//1e-265
	.quad 0x09201f4d0ff10390//1e-264
	.quad 0x0954272053ed4474//1e-263
	.quad 0x098930e868e89591//1e-262
	.quad 0x09bf7d228322baf5//1e-261
	.quad 0x09f3ae3591f5b4d9//1e-260
	.quad 0x0a2899c2f6732210//1e-259
	.quad 0x0a5ec033b40fea93//1e-258
	.quad 0x0a9338205089f29c//1e-257
	.quad 0x0ac8062864ac6f43//1e-256
	.quad 0x0afe07b27dd78b14//1e-255
	.quad 0x0b32c4cf8ea6b6ec//1e-254
	.quad 0x0b677603725064a8//1e-253
	.quad 0x0b9d53844ee47dd1//1e-252
	.quad 0x0bd25432b14ecea3//1e-251
	.quad 0x0c06e93f5da2824c//1e-250
	.quad 0x0c3ca38f350b22df//1e-249
	.quad 0x0c71e6398126f5cb//1e-248
	.quad 0x0ca65fc7e170b33e//1e-247
	.quad 0x0cdbf7b9d9cce00d//1e-246
	.quad 0x0d117ad428200c08//1e-245
	.quad 0x0d45d98932280f0a//1e-244
	.quad 0x0d7b4feb7eb212cd//1e-243
	.quad 0x0db111f32f2f4bc0//1e-242
	.quad 0x0de5566ffafb1eb0//1e-241
	.quad 0x0e1aac0bf9b9e65c//1e-240
	.quad 0x0e50ab877c142ffa//1e-239
	.quad 0x0e84d6695b193bf8//1e-238
	.quad 0x0eba0c03b1df8af6//1e-237
	.quad 0x0ef047824f2bb6da//1e-236
	.quad 0x0f245962e2f6a490//1e-235
	.quad 0x0f596fbb9bb44db4//1e-234
	.quad 0x0f8fcbaa82a16121//1e-233
	.quad 0x0fc3df4a91a4dcb5//1e-232
	.quad 0x0ff8d71d360e13e2//1e-231
	.quad 0x102f0ce4839198db//1e-230
	.quad 0x1063680ed23aff89//1e-229
	.quad 0x1098421286c9bf6b//1e-228
	.quad 0x10ce5297287c2f45//1e-227
	.quad 0x1102f39e794d9d8b//1e-226
	.quad 0x1137b08617a104ee//1e-225
	.quad 0x116d9ca79d89462a//1e-224
	.quad 0x11a281e8c275cbda//1e-223
	.quad 0x11d72262f3133ed1//1e-222
	.quad 0x120ceafbafd80e85//1e-221
	.quad 0x124212dd4de70913//1e-220
	.quad 0x12769794a160cb58//1e-219
	.quad 0x12ac3d79c9b8fe2e//1e-218
	.quad 0x12e1a66c1e139edd//1e-217
	.quad 0x1316100725988694//1e-216
	.quad 0x134b9408eefea839//1e-215
	.quad 0x13813c85955f2923//1e-214
	.quad 0x13b58ba6fab6f36c//1e-213
	.quad 0x13eaee90b964b047//1e-212
	.quad 0x1420d51a73deee2d//1e-211
	.quad 0x14550a6110d6a9b8//1e-210
	.quad 0x148a4cf9550c5426//1e-209
	.quad 0x14c0701bd527b498//1e-208
	.quad 0x14f48c22ca71a1bd//1e-207
	.quad 0x1529af2b7d0e0a2d//1e-206
	.quad 0x15600d7b2e28c65c//1e-205
	.quad 0x159410d9f9b2f7f3//1e-204
	.quad 0x15c91510781fb5f0//1e-203
	.quad 0x15ff5a549627a36c//1e-202
	.quad 0x16339874ddd8c623//1e-201
	.quad 0x16687e92154ef7ac//1e-200
	.quad 0x169e9e369aa2b597//1e-199
	.quad 0x16d322e220a5b17e//1e-198
	.quad 0x1707eb9aa8cf1dde//1e-197
	.quad 0x173de6815302e556//1e-196
	.quad 0x1772b010d3e1cf56//1e-195
	.quad 0x17a75c1508da432b//1e-194
	.quad 0x17dd331a4b10d3f6//1e-193
	.quad 0x18123ff06eea847a//1e-192
	.quad 0x1846cfec8aa52598//1e-191
	.quad 0x187c83e7ad4e6efe//1e-190
	.quad 0x18b1d270cc51055f//1e-189
	.quad 0x18e6470cff6546b6//1e-188
	.quad 0x191bd8d03f3e9864//1e-187
	.quad 0x1951678227871f3e//1e-186
	.quad 0x1985c162b168e70e//1e-185
	.quad 0x19bb31bb5dc320d2//1e-184
	.quad 0x19f0ff151a99f483//1e-183
	.quad 0x1a253eda614071a4//1e-182
	.quad 0x1a5a8e90f9908e0d//1e-181
	.quad 0x1a90991a9bfa58c8//1e-180
	.quad 0x1ac4bf6142f8eefa//1e-179
	.quad 0x1af9ef3993b72ab8//1e-178
	.quad 0x1b303583fc527ab3//1e-177
	.quad 0x1b6442e4fb671960//1e-176
	.quad 0x1b99539e3a40dfb8//1e-175
	.quad 0x1bcfa885c8d117a6//1e-174
	.quad 0x1c03c9539d82aec8//1e-173
	.quad 0x1c38bba884e35a7a//1e-172
	.quad 0x1c6eea92a61c3118//1e-171
	.quad 0x1ca3529ba7d19eaf//1e-170
	.quad 0x1cd8274291c6065b//1e-169
	.quad 0x1d0e3113363787f2//1e-168
	.quad 0x1d42deac01e2b4f7//1e-167
	.quad 0x1d779657025b6235//1e-166
	.quad 0x1dad7becc2f23ac2//1e-165
	.quad 0x1de26d73f9d764b9//1e-164
	.quad 0x1e1708d0f84d3de7//1e-163
	.quad 0x1e4ccb0536608d61//1e-162
	.quad 0x1e81fee341fc585d//1e-161
	.quad 0x1eb67e9c127b6e74//1e-160
	.quad 0x1eec1e43171a4a11//1e-159
	.quad 0x1f2192e9ee706e4b//1e-158
	.quad 0x1f55f7a46a0c89dd//1e-157
	.quad 0x1f8b758d848fac55//1e-156
	.quad 0x1fc1297872d9cbb5//1e-155
	.quad 0x1ff573d68f903ea2//1e-154
	.quad 0x202ad0cc33744e4b//1e-153
	.quad 0x2060c27fa028b0ef//1e-152
	.quad 0x2094f31f8832dd2a//1e-151
	.quad 0x20ca2fe76a3f9475//1e-150
	.quad 0x21005df0a267bcc9//1e-149
	.quad 0x2134756ccb01abfb//1e-148
	.quad 0x216992c7fdc216fa//1e-147
	.quad 0x219ff779fd329cb9//1e-146
	.quad 0x21d3faac3e3fa1f3//1e-145
	.quad 0x2208f9574dcf8a70//1e-144
	.quad 0x223f37ad21436d0c//1e-143
	.quad 0x227382cc34ca2428//1e-142
	.quad 0x22a8637f41fcad32//1e-141
	.quad 0x22de7c5f127bd87e//1e-140
	.quad 0x23130dbb6b8d674f//1e-139
	.quad 0x2347d12a4670c123//1e-138
	.quad 0x237dc574d80cf16b//1e-137
	.quad 0x23b29b69070816e3//1e-136
	.quad 0x23e7424348ca1c9c//1e-135
	.quad 0x241d12d41afca3c3//1e-134
	.quad 0x24522bc490dde65a//1e-133
	.quad 0x2486b6b5b5155ff0//1e-132
	.quad 0x24bc6463225ab7ec//1e-131
	.quad 0x24f1bebdf578b2f4//1e-130
	.quad 0x25262e6d72d6dfb0//1e-129
	.quad 0x255bba08cf8c979d//1e-128
	.quad 0x2591544581b7dec2//1e-127
	.quad 0x25c5a956e225d672//1e-126
	.quad 0x25fb13ac9aaf4c0f//1e-125
	.quad 0x2630ec4be0ad8f89//1e-124
	.quad 0x2665275ed8d8f36c//1e-123
	.quad 0x269a71368f0f3047//1e-122
	.quad 0x26d086c219697e2c//1e-121
	.quad 0x2704a8729fc3ddb7//1e-120
	.quad 0x2739d28f47b4d525//1e-119
	.quad 0x277023998cd10537//1e-118
	.quad 0x27a42c7ff0054685//1e-117
	.quad 0x27d9379fec069826//1e-116
	.quad 0x280f8587e7083e30//1e-115
	.quad 0x2843b374f06526de//1e-114
	.quad 0x2878a0522c7e7095//1e-113
	.quad 0x28aec866b79e0cba//1e-112
	.quad 0x28e33d4032c2c7f5//1e-111
	.quad 0x29180c903f7379f2//1e-110
	.quad 0x294e0fb44f50586e//1e-109
	.quad 0x2982c9d0b1923745//1e-108
	.quad 0x29b77c44ddf6c516//1e-107
	.quad 0x29ed5b561574765b//1e-106
	.quad 0x2a225915cd68c9f9//1e-105
	.quad 0x2a56ef5b40c2fc77//1e-104
	.quad 0x2a8cab3210f3bb95//1e-103
	.quad 0x2ac1eaff4a98553d//1e-102
	.quad 0x2af665bf1d3e6a8d//1e-101
	.quad 0x2b2bff2ee48e0530//1e-100
	.quad 0x2b617f7d4ed8c33e//1e-99
	.quad 0x2b95df5ca28ef40d//1e-98
	.quad 0x2bcb5733cb32b111//1e-97
	.quad 0x2c0116805effaeaa//1e-96
	.quad 0x2c355c2076bf9a55//1e-95
	.quad 0x2c6ab328946f80ea//1e-94
	.quad 0x2ca0aff95cc5b092//1e-93
	.quad 0x2cd4dbf7b3f71cb7//1e-92
	.quad 0x2d0a12f5a0f4e3e5//1e-91
	.quad 0x2d404bd984990e6f//1e-90
	.quad 0x2d745ecfe5bf520b//1e-89
	.quad 0x2da97683df2f268d//1e-88
	.quad 0x2ddfd424d6faf031//1e-87
	.quad 0x2e13e497065cd61f//1e-86
	.quad 0x2e48ddbcc7f40ba6//1e-85
	.quad 0x2e7f152bf9f10e90//1e-84
	.quad 0x2eb36d3b7c36a91a//1e-83
	.quad 0x2ee8488a5b445360//1e-82
	.quad 0x2f1e5aacf2156838//1e-81
	.quad 0x2f52f8ac174d6123//1e-80
	.quad 0x2f87b6d71d20b96c//1e-79
	.quad 0x2fbda48ce468e7c7//1e-78
	.quad 0x2ff286d80ec190dc//1e-77
	.quad 0x3027288e1271f513//1e-76
	.quad 0x305cf2b1970e7258//1e-75
	.quad 0x309217aefe690777//1e-74
	.quad 0x30c69d9abe034955//1e-73
	.quad 0x30fc45016d841baa//1e-72
	.quad 0x3131ab20e472914a//1e-71
	.quad 0x316615e91d8f359d//1e-70
	.quad 0x319b9b6364f30304//1e-69
	.quad 0x31d1411e1f17e1e3//1e-68
	.quad 0x32059165a6ddda5b//1e-67
	.quad 0x323af5bf109550f2//1e-66
	.quad 0x3270d9976a5d5297//1e-65
	.quad 0x32a50ffd44f4a73d//1e-64
	.quad 0x32da53fc9631d10d//1e-63
	.quad 0x3310747ddddf22a8//1e-62
	.quad 0x3344919d5556eb52//1e-61
	.quad 0x3379b604aaaca626//1e-60
	.quad 0x33b011c2eaabe7d8//1e-59
	.quad 0x33e41633a556e1ce//1e-58
	.quad 0x34191bc08eac9a41//1e-57
	.quad 0x344f62b0b257c0d2//1e-56
	.quad 0x34839dae6f76d883//1e-55
	.quad 0x34b8851a0b548ea4//1e-54
	.quad 0x34eea6608e29b24d//1e-53
	.quad 0x352327fc58da0f70//1e-52
	.quad 0x3557f1fb6f10934c//1e-51
	.quad 0x358dee7a4ad4b81f//1e-50
	.quad 0x35c2b50c6ec4f313//1e-49
	.quad 0x35f7624f8a762fd8//1e-48
	.quad 0x362d3ae36d13bbce//1e-47
	.quad 0x366244ce242c5561//1e-46
	.quad 0x3696d601ad376ab9//1e-45
	.quad 0x36cc8b8218854567//1e-44
	.quad 0x3701d7314f534b61//1e-43
	.quad 0x37364cfda3281e39//1e-42
	.quad 0x376be03d0bf225c7//1e-41
	.quad 0x37a16c262777579c//1e-40
	.quad 0x37d5c72fb1552d83//1e-39
	.quad 0x380b38fb9daa78e4//1e-38
	.quad 0x3841039d428a8b8f//1e-37
	.quad 0x38754484932d2e72//1e-36
	.quad 0x38aa95a5b7f87a0f//1e-35
	.quad 0x38e09d8792fb4c49//1e-34
	.quad 0x3914c4e977ba1f5c//1e-33
	.quad 0x3949f623d5a8a733//1e-32
	.quad 0x398039d665896880//1e-31
	.quad 0x39b4484bfeebc2a0//1e-30
	.quad 0x39e95a5efea6b347//1e-29
	.quad 0x3a1fb0f6be506019//1e-28
	.quad 0x3a53ce9a36f23c10//1e-27
	.quad 0x3a88c240c4aecb14//1e-26
	.quad 0x3abef2d0f5da7dd9//1e-25
	.quad 0x3af357c299a88ea7//1e-24
	.quad 0x3b282db34012b251//1e-23
	.quad 0x3b5e392010175ee6//1e-22
	.quad 0x3b92e3b40a0e9b4f//1e-21
	.quad 0x3bc79ca10c924223//1e-20
	.quad 0x3bfd83c94fb6d2ac//1e-19
	.quad 0x3c32725dd1d243ac//1e-18
	.quad 0x3c670ef54646d497//1e-17
	.quad 0x3c9cd2b297d889bc//1e-16
	.quad 0x3cd203af9ee75616//1e-15
	.quad 0x3d06849b86a12b9b//1e-14
	.quad 0x3d3c25c268497682//1e-13
	.quad 0x3d719799812dea11//1e-12
	.quad 0x3da5fd7fe1796495//1e-11
	.quad 0x3ddb7cdfd9d7bdbb//1e-10
	.quad 0x3e112e0be826d695//1e-9
	.quad 0x3e45798ee2308c3a//1e-8
	.quad 0x3e7ad7f29abcaf48//1e-7
	.quad 0x3eb0c6f7a0b5ed8d//1e-6
	.quad 0x3ee4f8b588e368f1//1e-5
	.quad 0x3f1a36e2eb1c432d//1e-4
	.quad 0x3f50624dd2f1a9fc//1e-3
	.quad 0x3f847ae147ae147b//1e-2
	.quad 0x3fb999999999999a//1e-1
	.quad 0x3ff0000000000000//1e0
	.quad 0x4024000000000000//1e1
	.quad 0x4059000000000000//1e2
	.quad 0x408f400000000000//1e3
	.quad 0x40c3880000000000//1e4
	.quad 0x40f86a0000000000//1e5
	.quad 0x412e848000000000//1e6
	.quad 0x416312d000000000//1e7
	.quad 0x4197d78400000000//1e8
	.quad 0x41cdcd6500000000//1e9
	.quad 0x4202a05f20000000//1e10
	.quad 0x42374876e8000000//1e11
	.quad 0x426d1a94a2000000//1e12
	.quad 0x42a2309ce5400000//1e13
	.quad 0x42d6bcc41e900000//1e14
	.quad 0x430c6bf526340000//1e15
	.quad 0x4341c37937e08000//1e16
	.quad 0x4376345785d8a000//1e17
	.quad 0x43abc16d674ec800//1e18
	.quad 0x43e158e460913d00//1e19
	.quad 0x4415af1d78b58c40//1e20
	.quad 0x444b1ae4d6e2ef50//1e21
	.quad 0x4480f0cf064dd592//1e22
	.quad 0x44b52d02c7e14af7//1e23
	.quad 0x44ea784379d99db4//1e24
	.quad 0x45208b2a2c280291//1e25
	.quad 0x4554adf4b7320335//1e26
	.quad 0x4589d971e4fe8402//1e27
	.quad 0x45c027e72f1f1281//1e28
	.quad 0x45f431e0fae6d721//1e29
	.quad 0x46293e5939a08cea//1e30
	.quad 0x465f8def8808b024//1e31
	.quad 0x4693b8b5b5056e17//1e32
	.quad 0x46c8a6e32246c99c//1e33
	.quad 0x46fed09bead87c03//1e34
	.quad 0x4733426172c74d82//1e35
	.quad 0x476812f9cf7920e3//1e36
	.quad 0x479e17b84357691b//1e37
	.quad 0x47d2ced32a16a1b1//1e38
	.quad 0x48078287f49c4a1d//1e39
	.quad 0x483d6329f1c35ca5//1e40
	.quad 0x48725dfa371a19e7//1e41
	.quad 0x48a6f578c4e0a061//1e42
	.quad 0x48dcb2d6f618c879//1e43
	.quad 0x4911efc659cf7d4c//1e44
	.quad 0x49466bb7f0435c9e//1e45
	.quad 0x497c06a5ec5433c6//1e46
	.quad 0x49b18427b3b4a05c//1e47
	.quad 0x49e5e531a0a1c873//1e48
	.quad 0x4a1b5e7e08ca3a8f//1e49
	.quad 0x4a511b0ec57e649a//1e50
	.quad 0x4a8561d276ddfdc0//1e51
	.quad 0x4ababa4714957d30//1e52
	.quad 0x4af0b46c6cdd6e3e//1e53
	.quad 0x4b24e1878814c9ce//1e54
	.quad 0x4b5a19e96a19fc41//1e55
	.quad 0x4b905031e2503da9//1e56
	.quad 0x4bc4643e5ae44d13//1e57
	.quad 0x4bf97d4df19d6057//1e58
	.quad 0x4c2fdca16e04b86d//1e59
	.quad 0x4c63e9e4e4c2f344//1e60
	.quad 0x4c98e45e1df3b015//1e61
	.quad 0x4ccf1d75a5709c1b//1e62
	.quad 0x4d03726987666191//1e63
	.quad 0x4d384f03e93ff9f5//1e64
	.quad 0x4d6e62c4e38ff872//1e65
	.quad 0x4da2fdbb0e39fb47//1e66
	.quad 0x4dd7bd29d1c87a19//1e67
	.quad 0x4e0dac74463a989f//1e68
	.quad 0x4e428bc8abe49f64//1e69
	.quad 0x4e772ebad6ddc73d//1e70
	.quad 0x4eacfa698c95390c//1e71
	.quad 0x4ee21c81f7dd43a7//1e72
	.quad 0x4f16a3a275d49491//1e73
	.quad 0x4f4c4c8b1349b9b5//1e74
	.quad 0x4f81afd6ec0e1411//1e75
	.quad 0x4fb61bcca7119916//1e76
	.quad 0x4feba2bfd0d5ff5b//1e77
	.quad 0x502145b7e285bf99//1e78
	.quad 0x50559725db272f7f//1e79
	.quad 0x508afcef51f0fb5f//1e80
	.quad 0x50c0de1593369d1b//1e81
	.quad 0x50f5159af8044462//1e82
	.quad 0x512a5b01b605557b//1e83
	.quad 0x516078e111c3556d//1e84
	.quad 0x5194971956342ac8//1e85
	.quad 0x51c9bcdfabc1357a//1e86
	.quad 0x5200160bcb58c16c//1e87
	.quad 0x52341b8ebe2ef1c7//1e88
	.quad 0x526922726dbaae39//1e89
	.quad 0x529f6b0f092959c7//1e90
	.quad 0x52d3a2e965b9d81d//1e91
	.quad 0x53088ba3bf284e24//1e92
	.quad 0x533eae8caef261ad//1e93
	.quad 0x53732d17ed577d0c//1e94
	.quad 0x53a7f85de8ad5c4f//1e95
	.quad 0x53ddf67562d8b363//1e96
	.quad 0x5412ba095dc7701e//1e97
	.quad 0x5447688bb5394c25//1e98
	.quad 0x547d42aea2879f2e//1e99
	.quad 0x54b249ad2594c37d//1e100
	.quad 0x54e6dc186ef9f45c//1e101
	.quad 0x551c931e8ab87173//1e102
	.quad 0x5551dbf316b346e8//1e103
	.quad 0x558652efdc6018a2//1e104
	.quad 0x55bbe7abd3781eca//1e105
	.quad 0x55f170cb642b133f//1e106
	.quad 0x5625ccfe3d35d80e//1e107
	.quad 0x565b403dcc834e12//1e108
	.quad 0x569108269fd210cb//1e109
	.quad 0x56c54a3047c694fe//1e110
	.quad 0x56fa9cbc59b83a3d//1e111
	.quad 0x5730a1f5b8132466//1e112
	.quad 0x5764ca732617ed80//1e113
	.quad 0x5799fd0fef9de8e0//1e114
	.quad 0x57d03e29f5c2b18c//1e115
	.quad 0x58044db473335def//1e116
	.quad 0x583961219000356b//1e117
	.quad 0x586fb969f40042c5//1e118
	.quad 0x58a3d3e2388029bb//1e119
	.quad 0x58d8c8dac6a0342a//1e120
	.quad 0x590efb1178484135//1e121
	.quad 0x59435ceaeb2d28c1//1e122
	.quad 0x59783425a5f872f1//1e123
	.quad 0x59ae412f0f768fad//1e124
	.quad 0x59e2e8bd69aa19cc//1e125
	.quad 0x5a17a2ecc414a03f//1e126
	.quad 0x5a4d8ba7f519c84f//1e127
	.quad 0x5a827748f9301d32//1e128
	.quad 0x5ab7151b377c247e//1e129
	.quad 0x5aecda62055b2d9e//1e130
	.quad 0x5b22087d4358fc82//1e131
	.quad 0x5b568a9c942f3ba3//1e132
	.quad 0x5b8c2d43b93b0a8c//1e133
	.quad 0x5bc19c4a53c4e697//1e134
	.quad 0x5bf6035ce8b6203d//1e135
	.quad 0x5c2b843422e3a84d//1e136
	.quad 0x5c6132a095ce4930//1e137
	.quad 0x5c957f48bb41db7c//1e138
	.quad 0x5ccadf1aea12525b//1e139
	.quad 0x5d00cb70d24b7379//1e140
	.quad 0x5d34fe4d06de5057//1e141
	.quad 0x5d6a3de04895e46d//1e142
	.quad 0x5da066ac2d5daec4//1e143
	.quad 0x5dd4805738b51a75//1e144
	.quad 0x5e09a06d06e26112//1e145
	.quad 0x5e400444244d7cab//1e146
	.quad 0x5e7405552d60dbd6//1e147
	.quad 0x5ea906aa78b912cc//1e148
	.quad 0x5edf485516e7577f//1e149
	.quad 0x5f138d352e5096af//1e150
	.quad 0x5f48708279e4bc5b//1e151
	.quad 0x5f7e8ca3185deb72//1e152
	.quad 0x5fb317e5ef3ab327//1e153
	.quad 0x5fe7dddf6b095ff1//1e154
	.quad 0x601dd55745cbb7ed//1e155
	.quad 0x6052a5568b9f52f4//1e156
	.quad 0x60874eac2e8727b1//1e157
	.quad 0x60bd22573a28f19d//1e158
	.quad 0x60f2357684599702//1e159
	.quad 0x6126c2d4256ffcc3//1e160
	.quad 0x615c73892ecbfbf4//1e161
	.quad 0x6191c835bd3f7d78//1e162
	.quad 0x61c63a432c8f5cd6//1e163
	.quad 0x61fbc8d3f7b3340c//1e164
	.quad 0x62315d847ad00087//1e165
	.quad 0x6265b4e5998400a9//1e166
	.quad 0x629b221effe500d4//1e167
	.quad 0x62d0f5535fef2084//1e168
	.quad 0x630532a837eae8a5//1e169
	.quad 0x633a7f5245e5a2cf//1e170
	.quad 0x63708f936baf85c1//1e171
	.quad 0x63a4b378469b6732//1e172
	.quad 0x63d9e056584240fe//1e173
	.quad 0x64102c35f729689f//1e174
	.quad 0x6444374374f3c2c6//1e175
	.quad 0x647945145230b378//1e176
	.quad 0x64af965966bce056//1e177
	.quad 0x64e3bdf7e0360c36//1e178
	.quad 0x6518ad75d8438f43//1e179
	.quad 0x654ed8d34e547314//1e180
	.quad 0x6583478410f4c7ec//1e181
	.quad 0x65b819651531f9e8//1e182
	.quad 0x65ee1fbe5a7e7861//1e183
	.quad 0x6622d3d6f88f0b3d//1e184
	.quad 0x665788ccb6b2ce0c//1e185
	.quad 0x668d6affe45f818f//1e186
	.quad 0x66c262dfeebbb0f9//1e187
	.quad 0x66f6fb97ea6a9d38//1e188
	.quad 0x672cba7de5054486//1e189
	.quad 0x6761f48eaf234ad4//1e190
	.quad 0x679671b25aec1d89//1e191
	.quad 0x67cc0e1ef1a724eb//1e192
	.quad 0x680188d357087713//1e193
	.quad 0x6835eb082cca94d7//1e194
	.quad 0x686b65ca37fd3a0d//1e195
	.quad 0x68a11f9e62fe4448//1e196
	.quad 0x68d56785fbbdd55a//1e197
	.quad 0x690ac1677aad4ab1//1e198
	.quad 0x6940b8e0acac4eaf//1e199
	.quad 0x6974e718d7d7625a//1e200
	.quad 0x69aa20df0dcd3af1//1e201
	.quad 0x69e0548b68a044d6//1e202
	.quad 0x6a1469ae42c8560c//1e203
	.quad 0x6a498419d37a6b8f//1e204
	.quad 0x6a7fe52048590673//1e205
	.quad 0x6ab3ef342d37a408//1e206
	.quad 0x6ae8eb0138858d0a//1e207
	.quad 0x6b1f25c186a6f04c//1e208
	.quad 0x6b537798f4285630//1e209
	.quad 0x6b88557f31326bbc//1e210
	.quad 0x6bbe6adefd7f06aa//1e211
	.quad 0x6bf302cb5e6f642a//1e212
	.quad 0x6c27c37e360b3d35//1e213
	.quad 0x6c5db45dc38e0c82//1e214
	.quad 0x6c9290ba9a38c7d1//1e215
	.quad 0x6cc734e940c6f9c6//1e216
	.quad 0x6cfd022390f8b837//1e217
	.quad 0x6d3221563a9b7323//1e218
	.quad 0x6d66a9abc9424feb//1e219
	.quad 0x6d9c5416bb92e3e6//1e220
	.quad 0x6dd1b48e353bce70//1e221
	.quad 0x6e0621b1c28ac20c//1e222
	.quad 0x6e3baa1e332d728f//1e223
	.quad 0x6e714a52dffc6799//1e224
	.quad 0x6ea59ce797fb817f//1e225
	.quad 0x6edb04217dfa61df//1e226
	.quad 0x6f10e294eebc7d2c//1e227
	.quad 0x6f451b3a2a6b9c76//1e228
	.quad 0x6f7a6208b5068394//1e229
	.quad 0x6fb07d457124123d//1e230
	.quad 0x6fe49c96cd6d16cc//1e231
	.quad 0x7019c3bc80c85c7f//1e232
	.quad 0x70501a55d07d39cf//1e233
	.quad 0x708420eb449c8843//1e234
	.quad 0x70b9292615c3aa54//1e235
	.quad 0x70ef736f9b3494e9//1e236
	.quad 0x7123a825c100dd11//1e237
	.quad 0x7158922f31411456//1e238
	.quad 0x718eb6bafd91596b//1e239
	.quad 0x71c33234de7ad7e3//1e240
	.quad 0x71f7fec216198ddc//1e241
	.quad 0x722dfe729b9ff153//1e242
	.quad 0x7262bf07a143f6d4//1e243
	.quad 0x72976ec98994f489//1e244
	.quad 0x72cd4a7bebfa31ab//1e245
	.quad 0x73024e8d737c5f0b//1e246
	.quad 0x7336e230d05b76cd//1e247
	.quad 0x736c9abd04725481//1e248
	.quad 0x73a1e0b622c774d0//1e249
	.quad 0x73d658e3ab795204//1e250
	.quad 0x740bef1c9657a686//1e251
	.quad 0x74417571ddf6c814//1e252
	.quad 0x7475d2ce55747a18//1e253
	.quad 0x74ab4781ead1989e//1e254
	.quad 0x74e10cb132c2ff63//1e255
	.quad 0x75154fdd7f73bf3c//1e256
	.quad 0x754aa3d4df50af0b//1e257
	.quad 0x7580a6650b926d67//1e258
	.quad 0x75b4cffe4e7708c0//1e259
	.quad 0x75ea03fde214caf1//1e260
	.quad 0x7620427ead4cfed6//1e261
	.quad 0x7654531e58a03e8c//1e262
	.quad 0x768967e5eec84e2f//1e263
	.quad 0x76bfc1df6a7a61bb//1e264
	.quad 0x76f3d92ba28c7d15//1e265
	.quad 0x7728cf768b2f9c5a//1e266
	.quad 0x775f03542dfb8370//1e267
	.quad 0x779362149cbd3226//1e268
	.quad 0x77c83a99c3ec7eb0//1e269
	.quad 0x77fe494034e79e5c//1e270
	.quad 0x7832edc82110c2f9//1e271
	.quad 0x7867a93a2954f3b8//1e272
	.quad 0x789d9388b3aa30a5//1e273
	.quad 0x78d27c35704a5e67//1e274
	.quad 0x79071b42cc5cf601//1e275
	.quad 0x793ce2137f743382//1e276
	.quad 0x79720d4c2fa8a031//1e277
	.quad 0x79a6909f3b92c83d//1e278
	.quad 0x79dc34c70a777a4d//1e279
	.quad 0x7a11a0fc668aac70//1e280
	.quad 0x7a46093b802d578c//1e281
	.quad 0x7a7b8b8a6038ad6f//1e282
	.quad 0x7ab137367c236c65//1e283
	.quad 0x7ae585041b2c477f//1e284
	.quad 0x7b1ae64521f7595e//1e285
	.quad 0x7b50cfeb353a97db//1e286
	.quad 0x7b8503e602893dd2//1e287
	.quad 0x7bba44df832b8d46//1e288
	.quad 0x7bf06b0bb1fb384c//1e289
	.quad 0x7c2485ce9e7a065f//1e290
	.quad 0x7c59a742461887f6//1e291
	.quad 0x7c9008896bcf54fa//1e292
	.quad 0x7cc40aabc6c32a38//1e293
	.quad 0x7cf90d56b873f4c7//1e294
	.quad 0x7d2f50ac6690f1f8//1e295
	.quad 0x7d63926bc01a973b//1e296
	.quad 0x7d987706b0213d0a//1e297
	.quad 0x7dce94c85c298c4c//1e298
	.quad 0x7e031cfd3999f7b0//1e299
	.quad 0x7e37e43c8800759c//1e300
	.quad 0x7e6ddd4baa009303//1e301
	.quad 0x7ea2aa4f4a405be2//1e302
	.quad 0x7ed754e31cd072da//1e303
	.quad 0x7f0d2a1be4048f90//1e304
	.quad 0x7f423a516e82d9ba//1e305
	.quad 0x7f76c8e5ca239029//1e306
	.quad 0x7fac7b1f3cac7433//1e307
	.quad 0x7fe1ccf385ebc8a0//1e308
	.quad 0x7ff0000000000000//1e309



.ENDIF
