USE [Configurateur]
GO

/****** Object:  View [dbo].[view_trx_porte_for_inventor]    Script Date: 2026-04-20 11:09:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO












CREATE VIEW [dbo].[view_trx_porte_for_inventor]
AS


SELECT *
	, CASE WHEN up.[Key] in ('QuoteNum','QuoteLine') THEN 'System.Int32'
		ELSE (SELECT top 1 vtp.ValueType FROM [Norlogic].[dbo].[Inv_TemplateDefaultParameter] vtp WHERE vtp.[Key]=up.[Key] )
		END ValueType
	FROM (

	SELECT por.uid
		,cast(qd.QuoteNum as int) as Quotenum
		,cast(qd.Quoteline as int) as QuoteLine
		--,od.ordernum
		--,od.orderline
		,CAST(CASE WHEN por.cadre_epaisseur_custo>0 THEN por.cadre_epaisseur_custo
			ELSE (SELECT ite.functional_value FROM Configurateur.dbo.ref_reference ref LEFT JOIN Configurateur.dbo.ref_item ite on ite.uid=ref.ref_item_UID
							WHERE ref.uid=por.cadre_epaisseur) END as nvarchar(max)) as ÉpaisseurMur
		,cast(por.ouverture_hauteur as nvarchar(max)) as HauteurOuverture
		,cast(por.ouverture_largeur as nvarchar(max)) as LargeurOuverture
		,cast((SELECT loc.fr FROM Configurateur.dbo.ref_reference ref LEFT JOIN Configurateur.dbo.ref_item ite on ite.uid=ref.ref_item_UID
							LEFT JOIN Configurateur.dbo.sys_localisation loc on loc.uid=ite.sys_localisation_uid
							WHERE ref.uid=por.porte_type) as nvarchar(max)) as Option1
		,cast(CASE WHEN por.sens_ouverture=561 THEN 'Droite' WHEN por.sens_ouverture=560 THEN 'Gauche' ELSE '' END as nvarchar(max)) as Option2
		,cast(isnull((SELECT r_seuil.inv_value FROM  Configurateur.dbo.ref_reference r_seuil WHERE r_seuil.uid=por.seuil_type),'') as nvarchar(max)) as Seuil
		,cast(CASE WHEN isnull(por.plaque_prot_ext_fini,'') <> '' THEN 'Oui' Else 'Non' END as nvarchar(max)) as PlaqueExt
		,cast(CASE WHEN isnull(por.plaque_prot_int_fini,'') <> '' THEN 'Oui' Else 'Non' END as nvarchar(max)) as PlaqueInt
		,cast(isnull((SELECT r_poi.inv_value FROM  Configurateur.dbo.ref_reference r_poi WHERE r_poi.uid=por.penture_poignee),'Aucune') as nvarchar(max)) as Poignée
		,cast(CASE WHEN ISNULL(por.plaque_prot_ext_fini,0) <> 0 THEN
					isnull((SELECT SUBSTRING(r_poi.inv_value, 1, CHARINDEX(',', r_poi.inv_value)-1)  FROM  Configurateur.dbo.ref_reference r_poi 
						WHERE r_poi.uid=por.plaque_prot_ext_fini),'Aucune') ELSE NULL END
			as nvarchar(max)) as MatPlaqueProtExt
		,cast(CASE WHEN ISNULL(por.plaque_prot_int_fini,0) <> 0 THEN
					isnull((SELECT SUBSTRING(r_poi.inv_value, 1, CHARINDEX(',', r_poi.inv_value)-1)  FROM  Configurateur.dbo.ref_reference r_poi 
						WHERE r_poi.uid=por.plaque_prot_int_fini),'Aucune') ELSE NULL END
			as nvarchar(max)) as MatPlaqueProtInt
		,cast(CASE WHEN ISNULL(por.plaque_prot_ext_fini,0) <> 0 THEN
					isnull((SELECT SUBSTRING(r_poi.inv_value, CHARINDEX(',', r_poi.inv_value)+1, LEN(r_poi.inv_value))  
						FROM  Configurateur.dbo.ref_reference r_poi 
						WHERE r_poi.uid=por.plaque_prot_ext_fini),'Aucune') ELSE NULL END
			as nvarchar(max)) as GagePlaqueProtExt
		,cast(CASE WHEN ISNULL(por.plaque_prot_int_fini,0) <> 0 THEN
					isnull((SELECT SUBSTRING(r_poi.inv_value, CHARINDEX(',', r_poi.inv_value)+1, LEN(r_poi.inv_value))  
						FROM  Configurateur.dbo.ref_reference r_poi 
						WHERE r_poi.uid=por.plaque_prot_int_fini),'Aucune') ELSE NULL END
			as nvarchar(max)) as GagePlaqueProtInt
		,CAST(isnull(por.plaque_prot_ext_hauteur,0) as nvarchar(max)) as HauteurPlaqueExt
		,CAST(isnull(por.plaque_prot_int_hauteur,0) as nvarchar(max)) as HauteurPlaqueInt
		,CAST((SELECT ite.functional_value FROM Configurateur.dbo.ref_reference ref LEFT JOIN Configurateur.dbo.ref_item ite on ite.uid=ref.ref_item_UID
							WHERE ref.uid=por.cadre_epaisseur) as nvarchar(max)) ÉpaisseurPorte
		,Cast(mat_ext.nom_intran_inventor as nvarchar(max)) as MatPorteExt
		,Cast(mat_int.nom_intran_inventor as nvarchar(max)) as MatPorteInt
		,Cast(Cast(mat_ext.gauge as nvarchar(max)) + 'ga' as nvarchar(max)) as GagePorteExt
		,Cast(Cast(mat_int.gauge as nvarchar(max)) + 'ga' as nvarchar(max)) as GagePorteInt
		,CAST(CASE WHEN por.penture_poignee=272 THEN 'Avec Clanche Ext.'
				WHEN por.penture_poignee=1048 THEN 'Avec Clanche Ext. Avec Serrure'
				WHEN por.penture_poignee=711 THEN 'Avec Clanche Ext. Sans Serrure'
				WHEN por.penture_poignee=710 THEN 'Sans Clanche Ext.'
				ELSE NULL END as nvarchar(max)) OptionVonDuprin
		,cast(isnull(
			CASE WHEN isnull(por.cl_fermoir,0) <> 0 THEN
					(SELECT r_fmoir.inv_value FROM  Configurateur.dbo.ref_reference r_fmoir WHERE r_fmoir.uid=por.cl_fermoir)
				 WHEN isnull(por.penture_fermoir,0) <> 0 THEN
					(SELECT r_fmoir.inv_value FROM  Configurateur.dbo.ref_reference r_fmoir WHERE r_fmoir.uid=por.penture_fermoir)
			ELSE 'Aucun' END
			,'') as nvarchar(max)) as Fermoir
		,cast(isnull((SELECT r_ramp.inv_value FROM  Configurateur.dbo.ref_reference r_ramp WHERE r_ramp.uid=por.rampe_type),'Aucune') as nvarchar(max)) as Rampe
		,Cast(Cast(mat_c_ext.gauge as nvarchar(max)) + 'ga' as nvarchar(max)) as GageCadreExt
		,Cast(Cast(mat_c_int.gauge as nvarchar(max)) + 'ga' as nvarchar(max)) as GageCadreInt
		,Cast(mat_c_ext.nom_intran_inventor as nvarchar(max))  as MatCadreExt
		,Cast(mat_c_int.nom_intran_inventor as nvarchar(max))  as MatCadreInt
		,cast(isnull(
			CASE WHEN isnull(por.fen_congelateur,0) <> 0 
				THEN (SELECT r_fen.inv_value FROM  Configurateur.dbo.ref_reference r_fen WHERE r_fen.uid=por.fen_congelateur)
				WHEN isnull(por.fen_refrigerateur,0) <> 0 
				THEN (SELECT r_fen.inv_value FROM  Configurateur.dbo.ref_reference r_fen WHERE r_fen.uid=por.fen_refrigerateur)
				ELSE NULL END 
			,'Aucune') as nvarchar(max)) as Fenêtre
		,cast(isnull((SELECT r_bal.inv_value FROM  Configurateur.dbo.ref_reference r_bal WHERE r_bal.uid=por.penture_balai),'Aucune') as nvarchar(max)) as OptionBalais
		,cast(isnull((SELECT r_chr.inv_value FROM  Configurateur.dbo.ref_reference r_chr WHERE r_chr.uid=por.pentures_type),'Aucune') as nvarchar(max)) as Charnière
		,cast(por.pentures_qte as nvarchar(max)) QtéCharnièreCentre
		--,*
	FROM Configurateur.dbo.trx_porte por
	JOIN [SQL02-Norbec].[NorbecCustom].[dbo].[QuoteDtl] qd on qd.number12=por.uid and qd.partnum='0902-00001' and qd.voidline<>1
	LEFT JOIN Configurateur.dbo.ref_reference ref_ext ON ref_ext.uid=por.porte_fini_ext
	LEFT JOIN Configurateur.dbo.uni_materiel mat_ext on mat_ext.ref_item_uid=ref_ext.ref_item_UID
	LEFT JOIN Configurateur.dbo.ref_reference ref_int ON ref_int.uid=por.porte_fini_int
	LEFT JOIN Configurateur.dbo.uni_materiel mat_int on mat_int.ref_item_uid=ref_int.ref_item_UID

	LEFT JOIN Configurateur.dbo.ref_reference ref_c_ext ON ref_c_ext.uid=por.cadre_fini_ext
	LEFT JOIN Configurateur.dbo.uni_materiel mat_c_ext on mat_c_ext.ref_item_uid=ref_c_ext.ref_item_UID
	LEFT JOIN Configurateur.dbo.ref_reference ref_c_int ON ref_c_int.uid=por.cadre_fini_int
	LEFT JOIN Configurateur.dbo.uni_materiel mat_c_int on mat_c_int.ref_item_uid=ref_c_int.ref_item_UID

	--LEFT JOIN [SQL02-Norbec].[NorbecCustom].[dbo].[OrderDtl] od on od.quotenum=qd.quotenum and od.quoteline=qd.quoteline and od.company=qd.company
	--WHERE qd.quotenum='292477'
	WHERE por.UID>60000-- por.uid=175547 --por.UID>90000--por.UID=175718--175641--175312 --por.UID>100000--

	) spor
  unpivot (
    Value
    for [Key] in (ÉpaisseurMur,HauteurOuverture, LargeurOuverture,option1, Option2,Seuil, PlaqueExt, PlaqueInt, Poignée,MatPlaqueProtExt
				,MatPlaqueProtInt,GagePlaqueProtExt,GagePlaqueProtInt,HauteurPlaqueExt,HauteurPlaqueInt, ÉpaisseurPorte, MatPorteExt
				,MatPorteInt,GagePorteExt,GagePorteInt, OptionVonDuprin, Fermoir, Rampe, GageCadreExt, GageCadreInt, MatCadreExt
				, MatCadreInt, Fenêtre, OptionBalais, Charnière, QtéCharnièreCentre)
  ) up
--ORDER by uid desc

GO


