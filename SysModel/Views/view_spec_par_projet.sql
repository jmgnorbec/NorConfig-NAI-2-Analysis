USE [Configurateur]
GO

/****** Object:  View [dbo].[view_spec_par_projet]    Script Date: 2026-04-20 11:06:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[view_spec_par_projet]
AS
WITH qd as
(SELECT number12, quotenum, quoteline, Prod_End_C, OrderNum, OrderLine, qd_groupe
		FROM OPENQUERY([SQL02-Norbec], '
		SELECT qd.number12, qd.quotenum, qd.quoteline, qd.Prod_End_C, od.ordernum, od.orderline
		, cast(qd.number01 as int) as qd_groupe, cast(od.number01 as int) as od_groupe
		FROM NorbecCustom.dbo.quotedtl qd
		LEFT JOIN NorbecCustom.dbo.OrderDtl od on od.company=qd.company and od.QuoteNum=qd.QuoteNum and od.QuoteLine=qd.QuoteLine
		WHERE qd.partnum = ''0901-00001''
		') AS sqd)
SELECT inv.Projet
	,inv.inv_qte 
	,(
		SELECT count(*)
		FROM Configurateur.dbo.trx_inv_bom ipp
		WHERE ipp.ParentUid = 0
			AND ipp.ItemSort <> ''
			AND ipp.ItemSort = 'P'
			AND ipp.Projet = inv.Projet
		) AS inv_qte_porte
	,spec.*
	,qd.*
FROM
	---- sub select par chambre uid contenant un sub select des cl par chambre uid
	(
	SELECT cl.trx_chambre_UID
		,cl.qte_pan
		,(
			SELECT sum(isnull(prt.porte_qte, 0))
			FROM Configurateur.dbo.trx_porte prt
			WHERE prt.trx_chambre_UID = cl.trx_chambre_UID
			) qte_porte
		,CASE WHEN isnull(ch.chambre_exterieure, 0) <> 0 THEN 1 ELSE 0 END AS chambre_exterieur
		,isnull(ch.[forme_contour_colonne], 0) + isnull(ch.[forme_colonne_pan], 0) AS colonne
		,CASE WHEN ch.jonctions_au_sol IN (75) THEN 1 ELSE 0 END AS NSF
		,(
			SELECT loc.fr FROM Configurateur.dbo.ref_reference ref
			LEFT JOIN Configurateur.dbo.ref_item ite ON ite.uid = ref.ref_item_UID
			LEFT JOIN Configurateur.dbo.sys_localisation loc ON loc.uid = ite.sys_localisation_uid
			WHERE ref.uid = ch.chambre_type
			) AS chambre_type
		,(
			SELECT loc.fr FROM Configurateur.dbo.ref_reference ref
			LEFT JOIN Configurateur.dbo.ref_item ite ON ite.uid = ref.ref_item_UID
			LEFT JOIN Configurateur.dbo.sys_localisation loc ON loc.uid = ite.sys_localisation_uid
			WHERE ref.uid = ch.plancher_revetement_1
			) plancher_revetement1
		,(
			SELECT loc.fr FROM Configurateur.dbo.ref_reference ref
			LEFT JOIN Configurateur.dbo.ref_item ite ON ite.uid = ref.ref_item_UID
			LEFT JOIN Configurateur.dbo.sys_localisation loc ON loc.uid = ite.sys_localisation_uid
			WHERE ref.uid = ch.plancher_revetement_2
			) plancher_revetement2
		,(
			SELECT loc.fr FROM Configurateur.dbo.ref_reference ref
			LEFT JOIN Configurateur.dbo.ref_item ite ON ite.uid = ref.ref_item_UID
			LEFT JOIN Configurateur.dbo.sys_localisation loc ON loc.uid = ite.sys_localisation_uid
			WHERE ref.uid = ch.parechoc_int
			) parechoc_int
		,(
			SELECT loc.fr FROM Configurateur.dbo.ref_reference ref
			LEFT JOIN Configurateur.dbo.ref_item ite ON ite.uid = ref.ref_item_UID
			LEFT JOIN Configurateur.dbo.sys_localisation loc ON loc.uid = ite.sys_localisation_uid
			WHERE ref.uid = ch.parechoc_ext
			) parechoc_ext
		,(
			SELECT loc.fr FROM Configurateur.dbo.ref_reference ref
			LEFT JOIN Configurateur.dbo.ref_item ite ON ite.uid = ref.ref_item_UID
			LEFT JOIN Configurateur.dbo.sys_localisation loc ON loc.uid = ite.sys_localisation_uid
			WHERE ref.uid = ch.plancher
			) AS plancher
		,ch.forme_coin_en_l
		,ch.forme_angle_45
		,ch.forme_autre_angle
		--- Compte les hauteurs différente des cloisons de mur, si 0 pas de mur
		,(
			SELECT count(*)
			FROM (
				SELECT DISTINCT hcl.hauteur
				FROM Configurateur.dbo.trx_cloison hcl
				WHERE hcl.trx_chambre_UID = cl.trx_chambre_UID
					AND hcl.type_cloison = 1
				) AS qcl
			) AS qte_hauteur
		--- Si y'a de la matiere de cales y doit y avoir des cales
		,CASE 
			WHEN ch.cales_mats > 0
				THEN 1
			ELSE 0
			END AS cales
		--- Les rampes sont sur les portes
		,(
			SELECT count(*)
			FROM Configurateur.dbo.trx_porte prt
			WHERE prt.trx_chambre_UID = cl.trx_chambre_UID
				AND prt.rampe_type <> 0
			) rampe
		--- Fenêtre de porte
		,(
			SELECT count(*)
			FROM Configurateur.dbo.trx_porte prt
			WHERE prt.trx_chambre_UID = cl.trx_chambre_UID
				AND (
					prt.fen_congelateur <> 0
					OR prt.fen_refrigerateur <> 0
					)
			) fenetre_porte
		,(
			SELECT count(*)
			FROM Configurateur.dbo.trx_chambre_vitre vit
			WHERE vit.trx_chambre_UID = cl.trx_chambre_UID
			) AS Ouverture_vitre
		--- Pas sur de ce que kit éléctrique est pour toi dans les spec de chambre ou de porte
		,isnull((
				SELECT loc.fr
				FROM Configurateur.dbo.ref_reference ref
				LEFT JOIN Configurateur.dbo.ref_item ite ON ite.uid = ref.ref_item_UID
				LEFT JOIN Configurateur.dbo.sys_localisation loc ON loc.uid = ite.sys_localisation_uid
				WHERE ref.uid = ch.controle1
				), '') + ' ' + isnull((
				SELECT loc.fr
				FROM Configurateur.dbo.ref_reference ref
				LEFT JOIN Configurateur.dbo.ref_item ite ON ite.uid = ref.ref_item_UID
				LEFT JOIN Configurateur.dbo.sys_localisation loc ON loc.uid = ite.sys_localisation_uid
				WHERE ref.uid = ch.controle2
				), '') + ' ' + isnull((
				SELECT loc.fr
				FROM Configurateur.dbo.ref_reference ref
				LEFT JOIN Configurateur.dbo.ref_item ite ON ite.uid = ref.ref_item_UID
				LEFT JOIN Configurateur.dbo.sys_localisation loc ON loc.uid = ite.sys_localisation_uid
				WHERE ref.uid = ch.controle3
				), '') + ' ' + isnull((
				SELECT loc.fr
				FROM Configurateur.dbo.ref_reference ref
				LEFT JOIN Configurateur.dbo.ref_item ite ON ite.uid = ref.ref_item_UID
				LEFT JOIN Configurateur.dbo.sys_localisation loc ON loc.uid = ite.sys_localisation_uid
				WHERE ref.uid = ch.controle4
				), '') AS controle
		--- porte_type 834 = CL-1650-E
		--,(SELECT count(*) from Configurateur.dbo.trx_porte prt where prt.trx_chambre_UID=cl.trx_chambre_UID and prt.porte_type=834) porte_electrique
		,(
			SELECT loc.fr FROM Configurateur.dbo.ref_reference ref
			LEFT JOIN Configurateur.dbo.ref_item ite ON ite.uid = ref.ref_item_UID
			LEFT JOIN Configurateur.dbo.sys_localisation loc ON loc.uid = ite.sys_localisation_uid
			WHERE ref.uid = ch.plaque_prot_int
			) plaque_prot_int
		,(
			SELECT loc.fr FROM Configurateur.dbo.ref_reference ref
			LEFT JOIN Configurateur.dbo.ref_item ite ON ite.uid = ref.ref_item_UID
			LEFT JOIN Configurateur.dbo.sys_localisation loc ON loc.uid = ite.sys_localisation_uid
			WHERE ref.uid = ch.plaque_prot_ext
			) plaque_prot_ext
	FROM (
		SELECT scl.trx_chambre_UID
			,sum(CASE 
					WHEN type_cloison = 1
						OR hauteur <> 1
						THEN ceiling(((isnull(scl.largeur, 1) * 12) / isnull(pml.PanMaxLarg, 1)) + 0.0001) * ceiling((scl.hauteur * 12) / isnull(pml.PanMaxLong, 1))
					ELSE ceiling(((isnull(mm.MaxMur, 1) * 12) / isnull(pml.PanMaxLarg, 1)) + 0.0001) * ceiling(((isnull(scl.largeur, 1) / isnull(mm.MaxMur, 1)) * 12) / isnull(pml.PanMaxLong, 1))
					END) AS qte_pan
		FROM Configurateur.dbo.trx_cloison scl
		LEFT OUTER JOIN (
			SELECT UID
				,CASE WHEN isnull(spml.larg_max_pan, 0) = 0 THEN 47
					ELSE spml.larg_max_pan
					END AS PanMaxLarg
				,CASE  WHEN isnull(spml.long_max_pan, 0) = 0 THEN 945
					ELSE spml.long_max_pan
					END AS PanMaxLong
			FROM Configurateur.dbo.trx_chambre AS spml
			) AS pml ON pml.UID = scl.trx_chambre_UID
		LEFT OUTER JOIN (
			SELECT trx_chambre_UID
				,isnull(MAX(largeur), 1) AS MaxMur
			FROM Configurateur.dbo.trx_cloison AS maxl
			WHERE (type_cloison = 1)
			GROUP BY trx_chambre_UID
			) AS mm ON mm.trx_chambre_UID = scl.trx_chambre_UID
		WHERE scl.type_cloison <> 4
			AND scl.trx_chambre_UID > 90000
		GROUP BY scl.trx_chambre_UID
		) cl
	LEFT JOIN Configurateur.dbo.trx_chambre ch ON ch.uid = cl.trx_chambre_UID
	WHERE ch.type_panneau NOT IN ('596','595','0')
	) AS spec
JOIN 
--[SQL02-Norbec].[NorbecCustom].[dbo].quotedtl qd ON qd.number12 = spec.trx_chambre_UID -- AND qd.partnum='0901-00001'
qd on qd.number12=spec.trx_chambre_UID
--[SQL02-Norbec].[NorbecCustom].[dbo].quotedtl qd ON qd.number12 = spec.trx_chambre_UID --AND qd.partnum = '0901-00001'
--- Lien inventor par quotenum quoteline qui devrait être 1:1 sur le trx_chambre_uid pour les panneau (pas la/les portes)
LEFT JOIN (
	SELECT MAx(inp.Projet) AS Projet
		,inp.QuoteNum
		,inp.QuoteLine
		,max(inp.Date_Added) Date_Added
		,Count(*) AS inv_qte
		,SUM(CASE 
				WHEN inp.ItemSort <> 'P'
					THEN 1
				ELSE 0
				END) AS inv_qte_pan
	FROM Configurateur.dbo.trx_inv_bom inp
	WHERE inp.ParentUid = 0
		AND inp.ItemSort <> ''
	GROUP BY inp.QuoteNum
		,inp.QuoteLine
	) AS inv ON inv.QuoteNum = qd.quotenum AND inv.QuoteLine = qd.quoteline

GO


