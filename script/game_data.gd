extends Node

var default = {
	'speed': 500,
	'gravity': 5000,
	'jump': 1250,
	'jump_max': 2,
	'anti_stun_owned': false,
	'max_inventory': 25,
	'weapon': null,
	'attack_radius': 1,
	'cooldown_duration': 0
}

var trash = {
	'Botol plastik': {
		'value': 5
	},
	'Kantung kertas': {
		'value': 5
	}, 
	'Gelas kertas': {
		'value': 5
	},
	'Botol kaca': {
		'value': 10
	},
	'Sepatu bekas': {
		'value': 10
	}
}

var items = {
	'Anti-gravitasi': {
		'value': 25
	}, 
	'Sepatu lompat tinggi': {
		'value': 25
	},
	'Sepatu kilat': {
		'value': 25
	}, 
	'Tatapan Medusa': {
		'value': 35
	},
	'Tangan pencuri': {
		'value': 35
	},
	'Tongkat meteor': {
		'value': 35
	},
	'Perisai Aegis': {
		'value': 45
	},
	'Sentuhan Midas': {
		'value': 45
	},
	'Tas superbesar': {
		'value': 45
	}
}

var recipes = {
	'Anti-gravitasi': {
		'materials': {'Kantung kertas': 3, 'Botol kaca': 1},
		'effects': {'gravity': 2500},
		'type': 'movement',
		'description': 'Mengurangi efek gravitasi sebesar 50%.'
	},
	'Sepatu lompat tinggi': {
		'materials': {'Sepatu bekas': 2, 'Botol plastik': 3},
		'effects': {'jump_max': 3, 'jump': 1750},
		'type': 'movement',
		'description': 'Menambah kekuatan lompatan sebanyak 40%, serta memungkinkan pemain melakukan triple-jump.'
	},
	'Sepatu kilat': {
		'materials': {'Sepatu bekas': 1, 'Gelas kertas': 4},
		'effects': {'speed': 750},
		'type': 'movement',
		'description': 'Menambah kecepatan pergerakan sebanyak 50%, serta mengurangi waktu cooldown serangan selama 4 detik.'
	},
	'Tatapan Medusa': {
		'materials': {'Botol kaca': 1},
		'effects': {'weapon': 'Tatapan Medusa', 'cooldown_duration': 5},
		'type': 'combat',
		'radius': 250,
		'description': 'Membekukan target selama 3 detik. Cooldown 5 detik.'
	},
	'Tangan pencuri': {
		'materials': {'Botol plastik': 1},
		'effects': {'weapon': 'Tangan pencuri', 'cooldown_duration': 10},
		'type': 'combat',
		'radius': 250,
		'description': 'Mencuri 1 item acak dari inventory target serta membekukan target selama 1 detik. Cooldown 10 detik.'
	},
	'Tongkat meteor': {
		'materials': {'Botol kaca': 1},
		'effects': {'weapon': 'Tongkat meteor', 'cooldown_duration': 8},
		'type': 'combat',
		'radius': 500,
		'description': 'Memunculkan 3 meteor yang akan mengikuti target, serta membekukan target selama 1 detik jika menabrak target. Cooldown 8 detik.'
	},
	'Perisai Aegis': {
		'materials': {'Kantung kertas': 1},
		'effects': {'anti_stun_owned': true},
		'type': 'defense',
		'description': 'Meniadakan efek knockback, mengurangi efek membeku sebesar 50% dan menghapuskan efek membeku selama 1 detik.'
	},
	'Sentuhan Midas': {
		'materials': {'Sepatu bekas': 1},
		'effects': {},
		'type': 'gathering',
		'description': 'Menggandakan poin yang didapat dari menjual barang di inventory.'
	},
	'Tas superbesar': {
		'materials': {'Gelas kertas': 1},
		'effects': {'max_inventory': 50},
		'type': 'gathering',
		'description': 'Menambah kapasitas inventory sebanyak 25, serta meniadakan efek item Tangan Pencuri.'
	}
}

var tips = [
	'Karakter yang kamu mainkan disebut sebagai "Spirits".',
	'Kamu dapat mengecek item yang digunakan oleh pemain lain di leaderboard.',
	'Efek serangan dari item "Tongkat meteor" sangat sulit dihindari di tempat sempit, namun serangannya menjadi kurang efektif.',
	'Item "Tatapan Medusa" menjadi sangat efektif jika dikombinasikan dengan item "Sepatu kilat" atau item "Sepatu lompat tinggi".',
	'Efek item "Tangan pencuri" dapat dibatalkan oleh item "Tas superbesar".',
	'Tadinya, item "Tangan pencuri" memiliki 10% kemungkinan untuk mencuri item, namun efek tersebut dihapus karena dapat membuat permainan menjadi tidak seimbang.',
	'Item "Tongkat meteor" merupakan counter dari dengan jarak serangan pendek seperti "Tatapan Medusa" atau "Tangan pencuri".',
	'Meski efek item "Anti-gravitasi" mirip dengan item "Sepatu lompat tinggi", item "Anti-gravitasi" memiliki fungsi yang berbeda. Item "Anti-gravitasi" lebih cocok digunakan dengan item jenis collecting, sementara itu item "Sepatu lompat tinggi" lebih cocok digunakan dengan item jenis combat.'
]
