USE [Configurateur]
GO

/****** Object:  View [dbo].[vw_uni_acier_mat_uid_sans_silkline]    Script Date: 2026-04-20 11:27:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[vw_uni_acier_mat_uid_sans_silkline]
AS
SELECT epi.uid
	,epi.cie
	,epi.matiere
	,epi.epais
	,epi.gauge
	,epi.larg
	,epi.texture
	,epi.peinture
	,epi.couleur
	,epi.priorite
	,epi.code_epic
	,epi.active
	,epi.commentaire
	,epi.codeqc
	,epi.code17
	,epi.partnum_indirect
	,epi.leadtime_indirect
	,epi.lot_econo_indirect
	,mat.uid AS mat_uid
	,CAST(loc.fr AS NVARCHAR(250)) AS nom_matiere
	,cou.Couleur AS nom_couleur
	,ref_item_uid
FROM dbo.uni_acier_epicor AS epi
LEFT OUTER JOIN dbo.uni_materiel AS mat ON mat.matiere = epi.matiere
	AND ISNULL(mat.type_peinture, N'') = epi.peinture
	AND mat.gauge = epi.gauge
	AND ISNULL(mat.couleur, 0) = epi.couleur
	AND mat.texture NOT LIKE 'Silkline%'
	AND epi.texture = CASE 
		WHEN isnull(mat.PROFILE, '') = '' THEN 'Lisse'
		WHEN mat.PROFILE = 'Embossé stucco' THEN 'Embossé'
		ELSE 'Lisse'
		END
LEFT OUTER JOIN dbo.ref_item AS ite ON ite.UID = mat.ref_item_uid
LEFT OUTER JOIN dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
LEFT OUTER JOIN dbo.uni_couleurs AS cou ON cou.uid = epi.couleur
WHERE (epi.active = 1) AND mat.actif = 1

GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "epi"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "mat"
            Begin Extent = 
               Top = 6
               Left = 262
               Bottom = 136
               Right = 461
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ite"
            Begin Extent = 
               Top = 6
               Left = 499
               Bottom = 136
               Right = 691
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "loc"
            Begin Extent = 
               Top = 6
               Left = 729
               Bottom = 136
               Right = 899
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cou"
            Begin Extent = 
               Top = 6
               Left = 937
               Bottom = 136
               Right = 1107
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 21
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_uni_acier_mat_uid_sans_silkline'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'= 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_uni_acier_mat_uid_sans_silkline'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_uni_acier_mat_uid_sans_silkline'
GO

