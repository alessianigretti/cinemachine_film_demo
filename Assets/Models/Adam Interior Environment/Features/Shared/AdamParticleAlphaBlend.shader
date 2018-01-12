Shader "Adam/Particles Alpha Blended" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
	_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
	Blend SrcAlpha OneMinusSrcAlpha
	ColorMask RGB
	Cull Off Lighting Off ZWrite Off

	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma target 5.0
			#pragma only_renderers d3d11
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_particles
			#pragma multi_compile_fog
			#pragma multi_compile _ VOLUMETRIC_FOG
			
			#include "UnityCG.cginc"
			#if VOLUMETRIC_FOG
				#include "../VolumetricFog/Shaders/VolumetricFog.cginc"
			#endif

			sampler2D _MainTex;
			fixed4 _TintColor;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				#if defined(SOFTPARTICLES_ON) || VOLUMETRIC_FOG
				float4 uvscreen : TEXCOORD2;
				#endif
			};
			
			float4 _MainTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				#if defined(SOFTPARTICLES_ON) || VOLUMETRIC_FOG
				o.uvscreen = ComputeScreenPos (o.vertex);
				#endif
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			sampler2D_float _CameraDepthTexture;
			float _InvFade;
			
			fixed4 frag (v2f i) : SV_Target
			{
				#if defined(SOFTPARTICLES_ON) || VOLUMETRIC_FOG
					half3 uvscreen = i.uvscreen.xyz/i.uvscreen.w;
					float scene01depth = Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uvscreen.xy));
					float linear01Depth = Linear01Depth(uvscreen.z);
				#endif

				#if defined(SOFTPARTICLES_ON)
					float fade = saturate (_InvFade * (scene01depth - linear01Depth) * _ProjectionParams.z);
					i.color.a *= fade;
				#endif
				
				fixed4 c = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
				UNITY_APPLY_FOG(i.fogCoord, c);

				#if VOLUMETRIC_FOG
					half4 fog = Fog(linear01Depth, uvscreen.xy);
					// Normaly should be applied with c.rgb = c.rgb * fog.a + fog.rgb, but
					// we want to tint it with the fog color instead.
					c.rgb *= fog.a * fog.rgb * 100;
				#endif

				return c;
			}
			ENDCG 
		}
	}	
}

FallBack "Particles/Alpha Blended"
}
