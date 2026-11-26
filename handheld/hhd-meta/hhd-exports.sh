export HHD_PPD_MASK=1 HHD_HORI_STEAM=1 HHD_HIDE_ALL=1 HHD_BUGREPORT=1 HHD_FPASTE='paste-cachyos'
export SDL_GAMECONTROLLERCONFIG=$(cat <<-END
060000000d0f00009601000000000000,Steam Controller (HHD),a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a3,righty:a4,lefttrigger:a2,righttrigger:a5,paddle1:b13,paddle2:b12,paddle3:b15,paddle4:b14,misc2:b11,misc3:b16,misc4:b17,crc:ea35,
060035ea0d0f00009601000001000000,Steam Controller (HHD),a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a3,righty:a4,lefttrigger:a2,righttrigger:a5,misc2:b11,
060000000d0f00009601000002000000,Steam Controller (HHD),a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a3,righty:a4,lefttrigger:a2,righttrigger:a5,paddle1:b13,paddle2:b12,misc2:b11,
060035ea0d0f00009601000003000000,Steam Controller (HHD),a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a3,righty:a4,lefttrigger:a2,righttrigger:a5,paddle1:b13,paddle2:b12,paddle3:b15,paddle4:b14,misc2:b11,
030022faef170000ed61000010010000,Legion Go Dual DInput,crc:fa22,platform:Linux,a:b0,b:b1,x:b2,y:b3,leftx:a0,lefty:a1,lefttrigger:b4,righttrigger:b5,back:b7,start:b6,steam:2,
$SDL_GAMECONTROLLERCONFIG
END
)
