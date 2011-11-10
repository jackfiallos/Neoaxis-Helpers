macroScript NeoMetiOperations
category:"Jack - MAX Script" 
tooltip:"NeoMeti Operations" 
buttontext:"NeoMeti Operations" 
Icon:#("cws",1)
(
	global FilePath = maxFilepath
	global mats = sceneMaterials
	global cacheMeshes = "Cache\Modelos\\"
	global cacheHightMaterial = "Cache\Texturas\\"

	global pathTypes = "/Types/"
	global pathHightMaterial = "/Materiales/"
	global pathTexturas = "/Texturas/"

	global thePath
	
	fn RemoveWhiteSpaces stringChar =
	(
		oldname = filterString stringChar " "  
		temp = oldname[1]  
		for i = 2 to oldname.count do  
		(  
			temp = temp + "_" + oldname[i]  
		)
		return temp
	)
	
	-- Exportar Objetos
	rollout rollOutExporter "Export Objects" width:208 height:136 rolledUp:true
	(
	
		button btnExporter "Exportar Objetos" pos:[16,16] width:192 height:40
		
		on btnExporter pressed do
		(
			i = 0
			-- Se recorren todos los objetos del escenario
			for numNodesgeometry in geometry do
			(
				numNodesgeometry.name = RemoveWhiteSpaces(numNodesgeometry.name)
				
				select numNodesgeometry
				makeDir (SavePathMesh = FilePath + pathTypes)
				currentIn = SavePathMesh + (numNodesgeometry.name + ".type")
				currentFile = openFile currentIn mode: "wt"
				
				format "type %\n" (numNodesgeometry.name) to:currentFile
				format "{\n" to:currentFile
					format "\tclass = Dynamic\n" to:currentFile
					format "\tallowEditorCreate = True\n" to:currentFile
					format "\tattachedObjects\n" to:currentFile
					format "\t{\n" to:currentFile
						format "\t\tmesh\n" to:currentFile
						format "\t\t{\n" to:currentFile
							format "\t\t\tmeshName = %%\n" (cacheMeshes) (numNodesgeometry.name + ".mesh") to:currentFile
							format "\t\t\ttoCollision = True\n" to:currentFile
							format "\t\t\talias = colisionable\n" to:currentFile
						format "\t\t}\n" to:currentFile
					format "\t}\n" to:currentFile
				format "}\n" to:currentFile
				close currentFile
				i = i + 1
			)
		
			-- Se recorren todos los objetos del escenario para generar archivos de hightMaterial
			for numNodesgeometry in geometry do
			(
				numNodesgeometry.name = RemoveWhiteSpaces(numNodesgeometry.name)
				
				select numNodesgeometry
				makeDir (SavePathHightMaterial = FilePath + pathHightMaterial)
				currentIn = SavePathHightMaterial + (numNodesgeometry.name + ".highMaterial")
				currentFile = openFile currentIn mode: "wt"
				
				format "highLevelMaterial %\n" (numNodesgeometry.name) to:currentFile
				format "{\n" to:currentFile
					format "\ttemplate = ShaderBaseMaterial\n" to:currentFile
					format "\tdiffuse1Map\n" to:currentFile
					format "\t{\n" to:currentFile
						format "\t\ttexture = %%\n" (cacheHightMaterial) (numNodesgeometry.name + ".png") to:currentFile
						format "\t\ttexCoord = TexCoord0\n" to:currentFile
					format "\t}\n" to:currentFile
				format "}\n" to:currentFile
				close currentFile
				i = i + 1
			)
			messagebox "La exportacion ha finalizado" title:".Type - .HightMaterial Exp"
		)
	)
	
	-- Operaciones con ProOptimizer
	rollout rollOutProOptimizer "Pro Optimizer Operations" width:208 height:136
	(
		button btnRemoveAll "Remover Todos" pos:[8,16] width:192 height:40
		button btnApplyAll "Aplicar a Todos" pos:[8,72] width:192 height:40
		
		on btnRemoveAll pressed do
		(
			for numNodesgeometry in geometry do
			(
				for m in numNodesgeometry.modifiers do
				(
					if classOf m==ProOptimizer do deleteModifier numNodesgeometry m
				)
			)
		)
		on btnApplyAll pressed do
		(
			for numNodesgeometry in geometry do
			(
				addModifier numNodesgeometry (ProOptimizer ())
				numNodesgeometry.modifiers[1].Calculate = true
				numNodesgeometry.modifiers[1].VertexPercent = 80
			)
		)
	)

	-- Centrar Pivote
	rollout rollOutPivotCenter "Object Pivot Center" width:208 height:136 rolledUp:true
	(
		button btnPivotCentar "Centrar Todos" pos:[16,16] width:192 height:40
		
		on btnPivotCentar pressed  do
		(
			for numNodesgeometry in geometry do
			(
				numNodesgeometry.pivot = numNodesgeometry.center
				numNodesgeometry.pivot.z = numNodesgeometry.min.z
			)
		)
	)
	
	-- Render utilizando flatiron
	rollout rollOutRender "Flatiron Render" width:208 height:136 rolledUp:true
	(
		button btnPivotCentar "Generar Render" pos:[16,16] width:192 height:40
		
		on btnPivotCentar pressed  do
		(
			makeDir (SavePathHightMaterial = FilePath + pathTexturas)			
			for numNodesgeometry in geometry do
			(
				--hide $*
				--unhide numNodesgeometry
				select numNodesgeometry
				numNodesgeometry.name = RemoveWhiteSpaces(numNodesgeometry.name)
				--render show:renderers.current
				
				--Flatiron.reset()
				--Flatiron.load c:\ConfiguracionFlatiron3dMax2011Last.uvf
				Flatiron.map_channel = 1
				Flatiron.stretch = 0.1
				Flatiron.padding = 4
				Flatiron.width = 512
				Flatiron.height = 512
				Flatiron.use_grooves = true
				Flatiron.groove_angle = 90
				Flatiron.use_ridges = true
				Flatiron.ridge_angle = 90
				Flatiron.overlap = 4
				Flatiron.illumination = true
				Flatiron.composite = true
				Flatiron.output = SavePathHightMaterial + (numNodesgeometry.name + ".png")
				Flatiron.element_str = "Ambient Occlusion"
				Flatiron.slot = "Diffuse Color"
				Flatiron.use_shell = true
				Flatiron.preview = false
				Flatiron.unwrap()
				Flatiron.bake false
				Flatiron.delete_shells false
				
				--unhide $*
			)
		)
	)
	
	rollout frmabout "Acerca de" width:208 height:136
	(
		HyperLink jackweb "By Jack Fiallos" pos:[8,112] width:110 height:15 address:"http://jackfiallos.com"
		label lbltitle "NeoMETI Exporter v1.0.4" pos:[8,8] width:112 height:15
		button btnabout "Información" pos:[8,32] width:65 height:25
		
		fn aboutWin = (
			local txt = ""
			txt += "NeoMeti Operations\n"
			txt += "By Jack Fiallos\n"
			txt += "http://jackfiallos.com\n\n"
			txt += "Descripcion: Exporta los elementos de un escenario \n\n"
			txt += "(.hightMaterials, texturas, .type\n"
			txt += "Beta version!\n"
			
			messagebox txt title:"Sobre Meti Exporter"
		)
		
		on btnabout pressed do
			aboutWin()
	)
	
	-- crea la ventana
	if MoCapFloater != undefined do (
		closerolloutfloater MoCapFloater
	)

	MoCapFloater = newRolloutFloater "NeoMeti :: Automatic Operations" 235 365 100 100
	addRollout rollOutProOptimizer MoCapFloater
	addRollout rollOutPivotCenter MoCapFloater
	addRollout rollOutExporter MoCapFloater
	addRollout rollOutRender MoCapFloater
	addRollout frmabout MoCapFloater
	
	createDialog rollOutProOptimizer
)