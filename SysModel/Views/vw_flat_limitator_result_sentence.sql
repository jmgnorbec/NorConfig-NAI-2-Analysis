USE [Configurateur]
GO

/****** Object:  View [dbo].[vw_flat_limitator_result_sentence]    Script Date: 2026-04-20 11:15:07 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_flat_limitator_result_sentence]
AS
SELECT DISTINCT 
                         lim.UID, lim.Nom, fli.UID AS sys_field_limitator_UID, rli.cond_flat_list + CHAR(13) + CHAR(10) 
                         + CASE WHEN rty.use_result_list = 1 THEN ' alors le limitateur ' + lim.Nom + ' ' + rty.text + ' du champs [' + fre.ForField + '] de la table [' + fre.ForTable + '] a: ' + flat_list
                          ELSE ' alors le limitateur ' + lim.Nom + ' rend le champs [' + fre.ForField + '] de la table [' + fre.ForTable + '] ' + rty.text END AS flat_limitator
FROM            dbo.sys_limitator AS lim LEFT OUTER JOIN
                         dbo.sys_field_limitator AS fli ON fli.sys_limitator_UID = lim.UID LEFT OUTER JOIN
                         dbo.sys_field_ref AS fre ON fre.UID = fli.sys_field_ref_UID LEFT OUTER JOIN
                         dbo.vw_flat_result_list AS rli ON rli.sys_limitator_UID = lim.UID LEFT OUTER JOIN
                         dbo.sys_limitator_result_type AS rty ON rty.uid = lim.sys_limitator_result_type_uid
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
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
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
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "lim"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 277
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "fli"
            Begin Extent = 
               Top = 6
               Left = 315
               Bottom = 118
               Right = 494
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "fre"
            Begin Extent = 
               Top = 6
               Left = 532
               Bottom = 135
               Right = 702
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "rli"
            Begin Extent = 
               Top = 6
               Left = 740
               Bottom = 118
               Right = 919
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "rty"
            Begin Extent = 
               Top = 6
               Left = 957
               Bottom = 135
               Right = 1127
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
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1965
         Width = 1965
         Width = 37590
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Ali' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_flat_limitator_result_sentence'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'as = 900
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_flat_limitator_result_sentence'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_flat_limitator_result_sentence'
GO

