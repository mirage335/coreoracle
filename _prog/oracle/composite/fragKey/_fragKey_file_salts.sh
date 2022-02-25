# Mitigates PBKDF2 PRF output bit-length bottlenecking. Allows independent keys to be generated with a strength exceeding the hash (HMAC) used.
# Generated from '/dev/urandom', simple counter/date values, OpenSSL cipher output, and similar. Any sufficiently long string of random hexits may be used.
# Salts need not be kept secret, but must be available for reuse.
# DANGER: Consumed by cascade ciphers. At least 768bits entropy strongly recommended for each salt. Simple functions not recommended.
_construct_passKey_salts() {
	cat << CZXWXcRMTo8EmM8i4d | xxd -p -r > "$safeTmp"/passKey_salt_01
1b9ee987cc9e7cac2af15345633238a1c3469afd5862f4fb71a795e85b82
0a25e851ec5482c191daab06d0d3f4b0d3e5dee092bc6f9f15ac675d01af
71b7714466e3a0c76fb6005882d8a62305bb300cadfce70d06e58e852228
f3c46e5f7ac4761f2d10bc2c9194b39a278b5f68ce74be159998dd1c7d81
eb3dfd12171174b61929239d7f4f2c32b170f8806b4d8b0c184205d66b04
3c7e44ba597d5ea1d171feeee7ef6730eacd5c19ca09187cee0a0e8d0d6f
2b4825d46d86f89dfcbdc96c
CZXWXcRMTo8EmM8i4d
	
	cat << CZXWXcRMTo8EmM8i4d | xxd -p -r > "$safeTmp"/passKey_salt_02
84eced78b4144f385567ec49b7f1ccda6f1c5257fcbd63816a3bd6647782
fc25e0e1bdb263476179b87a39e24ccb5c2f360603bb5f20f48818787ec4
47c514d8f97cb2b1173650bafe8d88b3c26c35cdd211ef309fd62092255a
1674ca56b2a39b6591c90bb9bc6bdaf32a560ed0eeddfcfcfa758fe381d9
1bbddda3c236198f8db0956b95a0417b3f499fe64bd87558528039cd1a9c
a44241f846d33a59c41ad2dbc46a102ea72a8d1daba6c826e892bc3f6c8e
99623f1b60b406f3fe377ab0
CZXWXcRMTo8EmM8i4d
	
	cat << CZXWXcRMTo8EmM8i4d | xxd -p -r > "$safeTmp"/passKey_salt_03
15560a9f24bdbc855b53e9b82c1f53c2e8801eae607ad9d94987d0cde493
f80c558b023ed980d6bff7f017012771e9e6485d96704691e332603d0b46
3f6013fab06553343af144612a1d094fce7d68e68e555e1369e78d599942
4c717389c784923d1a405cc27241c5d96e1362542807d87fd2e5337b23dd
78f5e6252c3e41c10f3b545d91515b0ea523e59cea0fa395dac19a97abcc
162270b7bf20e2d6479ab7e2456c0da98b0a12e72b63dfa629155ed399b1
24c110d7bc138254e31d49a8
CZXWXcRMTo8EmM8i4d
	
	cat << CZXWXcRMTo8EmM8i4d | xxd -p -r > "$safeTmp"/passKey_salt_04
98b39b96aed2588d282e91bcd0eba0946fbcf6cbf9c2f19f528153d42865
246ed69281ca188bf46ca7bd529070392e491483f9b3f0988d993911b3a1
6c45db03a6038a3352a2b3c508435cfe6207b00bfd5d74606a68de9f1ebe
7c3cf2cc83746e59cee74b48cca89c5d7e3e12bc493e0463b479ef1d9604
4227c048676669725fa89d818cfc61a070e1c4c02c352aa5547321c8fc14
57b90ac70c24ece33e94266e4c08342968c02f26dd7e328b41accbf2ba42
7237a878fe0ea05d0e4ff3a8
CZXWXcRMTo8EmM8i4d
	
	cat << CZXWXcRMTo8EmM8i4d | xxd -p -r > "$safeTmp"/passKey_salt_05
f86d1e5fe5efedd910f05a70583c444304d1a735f18d37dd27c31606db54
086120c5652e5bc06afb4bbf9979179ed7bcd5c3ada741f221109f5a94be
e000c99a1fb7333dc4a0780778cf6e447a3ab4f0a8c47ab1a2a8301ff2a2
1222803a70b87099b8afd168ddc2b5a5d234eaf91326f7457966948250de
ed24e65151a63376404ab1ba09a0a58b5f8b3925ddc096aef8f87bc139e1
19a7dce0afb16bff8d41207405f2263346ea75fedc43ac11468934e6e07f
e3b521a974255882368191d7
CZXWXcRMTo8EmM8i4d
	
	cat << CZXWXcRMTo8EmM8i4d | xxd -p -r > "$safeTmp"/passKey_salt_06
2472ce5b03d1f78f446c1372a8368b2af2c39e4235bac9fb6585b4fd72ce
eb3303fa24fe0decf0f34206900e144574841d42cd03a239a40b5931c7f7
d0876baa860a296e0bf2f0c7fa12b9741f80a07adbf88466ef7bfe59e6eb
16fa2c0f259ed1a33542a02eab3d49a724dc1a35b9e5324f41fcc009d1e5
350a7ead3e5a272ba57431dddcbd032ff1b32c74f97e5879f40f17b78e44
aefba2ffeb8e8f44cf892298e1939cf82d95804c2a3f4a45d9386f5cd01b
517eea0710849eb1945288f5
CZXWXcRMTo8EmM8i4d
	
	cat << CZXWXcRMTo8EmM8i4d | xxd -p -r > "$safeTmp"/passKey_salt_07
2155310ea2ea8c359b69a4e5ee35d6cec7171a48b0e5934d2edf3e68894a
ea3a586192fcee80e0c5836e66643278f6703916e89ab4e60f2aaaddea99
46ffc1cec158c6512a731fe231dc3b12975c9b43d26284debd35ee591756
1fffa89a83535c6744fcab8f962e6c90d5f3e07227052c48e9f5c42988dd
5e3924c7a91f4c5fafa35ec032b27f78f2d3db09d034fe172e5df667f45b
b25ed7207a2ed8151a037f6a6022e552d3f23c3ecc5d087f1df7298fa7fc
c80f1d8785b9d4464459076b
CZXWXcRMTo8EmM8i4d
	
	cat << CZXWXcRMTo8EmM8i4d | xxd -p -r > "$safeTmp"/passKey_salt_08
44f3d4f7af77630c484fad4fd57cdb08c743747573ecb87fc64a44bcfecd
5a218b30b0360b13e56d1835e10043b70d31befa390143a82f9e45675604
09baf6bee727286b26c8fd4574ae941bca870b69f9b50ec7e152d0ab82b3
2490fe5c0649ae7ec4dfee43c74581f55db6b90bac5f835caf57ac94219f
35976335961e250c2520728d3375ae544a5b09c2fff99412b063ea225c8d
cbd3b8d4a1594ff30427a895d43e80b4ca30364c578d74e61655c4870a9b
369c78dd6a0f2c5e2b68c107
CZXWXcRMTo8EmM8i4d
	
	cat << CZXWXcRMTo8EmM8i4d | xxd -p -r > "$safeTmp"/passKey_salt_09
199cf8e0d8152bb53a3c6e285774c4caaebc35e36177abb692b8dcd2599a
926208a251071b02fa8ae5d84e3d3ed4cdc06288d343f72072d1d1f303a3
01bb8c202aee5a889258fe1e49b57be918e4888664276e0fa4286e91c41b
aad143ac777c6d066b0aceeb8d640d4baa5f89726338f8695110985a941b
5f497daa3b706b1bf575a7340bb3cb8e13b168233bde1e4db02f026c8069
80ee60b0dff8bae9283aee320a6c4f488ca20255187309206d8068095641
8d606b4b56f9dbedf290b51d
CZXWXcRMTo8EmM8i4d
	
	cat << CZXWXcRMTo8EmM8i4d | xxd -p -r > "$safeTmp"/passKey_salt_10
32a32de0c4cbfd29f87fcf25f900a86b7089afd2f711d3d50f566cccd640
9ecaacf879945f0202455a999c1ff688f32fffe45faa98ffd8a45049c153
85b2eedaae3e5c0f074c17f8577bcb4a6e4ac86562aeb1690b1d9970bd83
c5e1b1d751777b5d58974fb10b199148cbe5fad6921f6123bc373ad89a93
b66046d95268d9a5b43a89e1c66fec81fbbb21fbe449e0d26f19cea068c8
83558a1f3eb505c7feb15ee2a6b734bbed203a61e713dbab1153c7659f80
b11ca36ca907eaa2b483b653
CZXWXcRMTo8EmM8i4d
	
	cat << CZXWXcRMTo8EmM8i4d | xxd -p -r > "$safeTmp"/passKey_salt_11
c8919f99836c09d34da0692b7d4af52b17847218fb20fafd5f7383dde536
e51f4510dc138a69ec62e7e2e244d8645c00ab0843ad30cc01858870344a
affea53d8ed09336a8f84008f60920e84536aa2e591da8139fc6b27448f7
7de1db0c37f3db93bf3a56c3835e0bd20de12b5ab7a39010d19cd6068bfb
f0550a01dc15c88bb99bbcda5cc87179da4609576191dffc85415b068f72
92df2f2ebd61296cafe18c001102995ff3374a2778b8f952f6347673e07e
df5617a2206963528153a795
CZXWXcRMTo8EmM8i4d
	
	cat << CZXWXcRMTo8EmM8i4d | xxd -p -r > "$safeTmp"/passKey_salt_12
535338232329e70e1a4257fb888949c1ebd3398af217b363e9c06fbca30a
11804b9197ce4a6efb072103709f40779b71d40b773b5fd2be8aa51f5d76
91cf4d767ef23e5a1ff3797c3e159dcea8a8f2d5b9cbeb3822bebb143f76
bfbb9ce125408de01434560b435020d39b19658b1d7eac419bd51e796fa1
2186b7e7af2b1b390d5f5a23a3e02841f76ea38d6a16760f44c893175243
52b4913f8f9d259df0518a303634274a08fb580bc631774167959810c253
e97a1dfe2f0dd499d5a1952f
CZXWXcRMTo8EmM8i4d
}
