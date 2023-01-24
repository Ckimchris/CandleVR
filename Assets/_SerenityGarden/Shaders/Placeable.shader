// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Tripp/SerenityGarden/Placeable"
{
	Properties
	{
		_BaseColorMaskMap("Base Color Mask Map", 2D) = "white" {}
		_RMetalicnessGAmbientOcclusionBEmissionMaskASmoothness("(R) Metalicness (G) Ambient Occlusion (B) Emission Mask (A) Smoothness", 2D) = "white" {}
		_BumpMap("Normal", 2D) = "bump" {}
		_Layer4("Layer 4", Color) = (0,0,0,0)
		_Layer3("Layer 3", Color) = (0,0,0,0)
		_Layer2("Layer 2", Color) = (0,0,0,0)
		_Layer1("Layer 1", Color) = (0,0,0,0)
		_Energy("Energy", Range( 0 , 1)) = 0
		[HDR]EmissionColor("EmissionColor", Color) = (0,0,0,0)
		_AlphaMod("Alpha Mod", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			half3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _BumpMap;
		uniform half4 _BumpMap_ST;
		uniform sampler2D _BaseColorMaskMap;
		uniform half4 _BaseColorMaskMap_ST;
		uniform half4 _Layer1;
		uniform half4 _Layer2;
		uniform half4 _Layer3;
		uniform half4 _Layer4;
		uniform half4 EmissionColor;
		uniform sampler2D _RMetalicnessGAmbientOcclusionBEmissionMaskASmoothness;
		uniform half4 _RMetalicnessGAmbientOcclusionBEmissionMaskASmoothness_ST;
		uniform half _Energy;
		uniform half _AlphaMod;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_BumpMap = i.uv_texcoord * _BumpMap_ST.xy + _BumpMap_ST.zw;
			o.Normal = UnpackNormal( tex2D( _BumpMap, uv_BumpMap ) );
			float2 uv_BaseColorMaskMap = i.uv_texcoord * _BaseColorMaskMap_ST.xy + _BaseColorMaskMap_ST.zw;
			half4 tex2DNode162 = tex2D( _BaseColorMaskMap, uv_BaseColorMaskMap );
			half layeredBlendVar164 = tex2DNode162.r;
			half4 layeredBlend164 = ( lerp( _Layer1,_Layer2 , layeredBlendVar164 ) );
			half layeredBlendVar167 = tex2DNode162.g;
			half4 layeredBlend167 = ( lerp( layeredBlend164,_Layer3 , layeredBlendVar167 ) );
			half layeredBlendVar170 = tex2DNode162.b;
			half4 layeredBlend170 = ( lerp( layeredBlend167,_Layer4 , layeredBlendVar170 ) );
			o.Albedo = layeredBlend170.rgb;
			float2 uv_RMetalicnessGAmbientOcclusionBEmissionMaskASmoothness = i.uv_texcoord * _RMetalicnessGAmbientOcclusionBEmissionMaskASmoothness_ST.xy + _RMetalicnessGAmbientOcclusionBEmissionMaskASmoothness_ST.zw;
			half4 tex2DNode163 = tex2D( _RMetalicnessGAmbientOcclusionBEmissionMaskASmoothness, uv_RMetalicnessGAmbientOcclusionBEmissionMaskASmoothness );
			half clampResult161 = clamp( _Energy , 0.0 , 1.0 );
			half clampResult153 = clamp( ( tex2DNode163.b + ( clampResult161 + -1.0 ) ) , 0.0 , 1.0 );
			float3 ase_worldPos = i.worldPos;
			half3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			half3 ase_worldNormal = WorldNormalVector( i, half3( 0, 0, 1 ) );
			half lerpResult190 = lerp( 6.0 , 4.0 , clampResult161);
			half fresnelNdotV177 = dot( ase_worldNormal, ase_worldViewDir );
			half fresnelNode177 = ( 0.0 + lerpResult190 * pow( 1.0 - fresnelNdotV177, lerpResult190 ) );
			half blendOpSrc179 = clampResult153;
			half blendOpDest179 = fresnelNode177;
			o.Emission = ( EmissionColor * ( saturate( ( 1.0 - ( 1.0 - blendOpSrc179 ) * ( 1.0 - blendOpDest179 ) ) )) ).rgb;
			o.Metallic = tex2DNode163.r;
			o.Smoothness = tex2DNode163.a;
			o.Occlusion = tex2DNode163.g;
			o.Alpha = ( tex2DNode162.a * _AlphaMod );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18935
244;416;1474;365;1635.162;441.3657;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;160;-1659.593,127.0894;Inherit;False;Property;_Energy;Energy;8;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;161;-1273.494,127.3894;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-1270.494,382.3894;Inherit;False;Constant;_Float2;Float 2;2;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-1170.938,514.4555;Inherit;False;Constant;_FresnelStart;Fresnel Start;10;0;Create;True;0;0;0;False;0;False;6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-1177.438,643.1557;Inherit;False;Constant;_FresnelFinish;Fresnel Finish;10;0;Create;True;0;0;0;False;0;False;4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;163;-1192.328,-127.1573;Inherit;True;Property;_RMetalicnessGAmbientOcclusionBEmissionMaskASmoothness;(R) Metalicness (G) Ambient Occlusion (B) Emission Mask (A) Smoothness;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;159;-997.4934,257.3894;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;162;-1176.343,-757.3264;Inherit;True;Property;_BaseColorMaskMap;Base Color Mask Map;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;190;-899.2376,517.0557;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;154;-741.4931,126.3894;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;165;-827.2866,-1015.523;Inherit;False;Property;_Layer1;Layer 1;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;166;-828.2866,-757.5231;Inherit;False;Property;_Layer2;Layer 2;6;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;169;-570.5627,-633.4595;Inherit;False;Property;_Layer3;Layer 3;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LayeredBlendNode;164;-559.059,-887.1137;Inherit;False;6;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;177;-588.153,383.9916;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;153;-505.4933,126.3894;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;179;-299.4169,258.9554;Inherit;True;Screen;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LayeredBlendNode;167;-301.3351,-760.0502;Inherit;False;6;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;176;-313.6451,3.40222;Inherit;False;Property;EmissionColor;EmissionColor;9;1;[HDR];Create;False;0;0;0;False;0;False;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;171;-314.4397,-504.4776;Inherit;False;Property;_Layer4;Layer 4;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;191;-1150.633,-382.0124;Inherit;False;Property;_AlphaMod;Alpha Mod;10;0;Create;True;0;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;180;-144.4239,-254.3267;Inherit;True;Property;_BumpMap;Normal;3;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;192;-753.5986,-381.1707;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LayeredBlendNode;170;-45.21179,-632.0682;Inherit;False;6;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;16.43621,128.9837;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;389.1354,-256.1736;Half;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Tripp/SerenityGarden/Placeable;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0;True;True;0;True;Transparent;;Transparent;ForwardOnly;18;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;2;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;161;0;160;0
WireConnection;159;0;161;0
WireConnection;159;1;157;0
WireConnection;190;0;188;0
WireConnection;190;1;189;0
WireConnection;190;2;161;0
WireConnection;154;0;163;3
WireConnection;154;1;159;0
WireConnection;164;0;162;1
WireConnection;164;1;165;0
WireConnection;164;2;166;0
WireConnection;177;2;190;0
WireConnection;177;3;190;0
WireConnection;153;0;154;0
WireConnection;179;0;153;0
WireConnection;179;1;177;0
WireConnection;167;0;162;2
WireConnection;167;1;164;0
WireConnection;167;2;169;0
WireConnection;192;0;162;4
WireConnection;192;1;191;0
WireConnection;170;0;162;3
WireConnection;170;1;167;0
WireConnection;170;2;171;0
WireConnection;178;0;176;0
WireConnection;178;1;179;0
WireConnection;0;0;170;0
WireConnection;0;1;180;0
WireConnection;0;2;178;0
WireConnection;0;3;163;1
WireConnection;0;4;163;4
WireConnection;0;5;163;2
WireConnection;0;9;192;0
ASEEND*/
//CHKSM=9305A0DF48A232D9CDB9192920A4AF72DA2A9039