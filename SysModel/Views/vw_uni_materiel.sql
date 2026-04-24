USE [Configurateur]
GO

/****** Object:  View [dbo].[vw_uni_materiel]    Script Date: 2026-04-20 11:28:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_uni_materiel]
AS
SELECT        uni.uid, uni.matiere, uni.couleur, coul.Couleur AS nom_couleur, coul.Code_QC, coul.Code_17, uni.texture, CASE WHEN isnull(uni.PROFILE, '') = '' THEN 'Lisse' ELSE uni.PROFILE END AS profile, uni.gauge, uni.type_peinture, 
                         uni.actif, uni.ref_item_uid, loc.fr AS nom_spec, uni.Nai_pricing_nom, uni.Nai_pricing_code, coul.bouchon, uni.gris_blanc, coul.silicone, uni.crayon, uni.coin_prot, coul.vis_trois_quart, uni.nom_intran_inventor, uni.largpan_max, 
                         ISNULL(mat.densite, 0) + ISNULL(pei.densite_pi3_metal, 0) AS densite_pi3, uni.inv_epais_str, CASE WHEN isnull(loc.fr, '') = '' THEN isnull(uni.matiere, '') + CASE WHEN isnull(uni.gauge, '') 
                         = '' THEN '' ELSE ' ' + CAST(isnull(uni.gauge, '') AS nvarchar) + 'ga' END + CASE WHEN isnull(uni.couleur, '') = '' THEN '' ELSE isnull(' ' + coul.Couleur, '') END + CASE WHEN isnull(uni.texture, '') 
                         = '' THEN '' ELSE isnull(' ' + uni.texture, '') END + CASE WHEN isnull(uni.profile, '') = '' THEN '' ELSE isnull(' ' + uni.profile, '') END ELSE loc.fr END AS merge_nom, uni.type_matiere
FROM            dbo.uni_materiel AS uni LEFT OUTER JOIN
                         dbo.uni_couleurs AS coul ON coul.uid = uni.couleur LEFT OUTER JOIN
                         dbo.ref_item AS item ON item.UID = uni.ref_item_uid LEFT OUTER JOIN
                         dbo.sys_localisation AS loc ON loc.UID = item.sys_localisation_uid LEFT OUTER JOIN
                         dbo.uni_matiere AS mat ON mat.matiere = uni.matiere LEFT OUTER JOIN
                         dbo.uni_type_peinture AS pei ON pei.type_peinture = uni.type_peinture
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
         Begin Table = "uni"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 218
            End
            DisplayFlags = 280
            TopColumn = 15
         End
         Begin Table = "coul"
            Begin Extent = 
               Top = 6
               Left = 256
               Bottom = 135
               Right = 426
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "item"
            Begin Extent = 
               Top = 6
               Left = 464
               Bottom = 135
               Right = 656
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "loc"
            Begin Extent = 
               Top = 6
               Left = 694
               Bottom = 135
               Right = 864
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "mat"
            Begin Extent = 
               Top = 6
               Left = 902
               Bottom = 101
               Right = 1072
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pei"
            Begin Extent = 
               Top = 6
               Left = 1110
               Bottom = 101
               Right = 1293
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
      Begin ColumnWidths = 28
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
      ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_uni_materiel'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'   Width = 1500
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
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
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
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_uni_materiel'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_uni_materiel'
GO

