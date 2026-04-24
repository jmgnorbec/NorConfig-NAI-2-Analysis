USE [Configurateur]
GO

/****** Object:  View [dbo].[vw_cond_value_full_list]    Script Date: 2026-04-20 11:11:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_cond_value_full_list]
AS
SELECT        ref.UID AS ref_uid, loc.fr, cond.UID AS cond_uid, cond.sys_limitator_UID, cof.UID AS cond_sys_field_ref_uid
FROM            dbo.sys_condition AS cond INNER JOIN
                         dbo.sys_field_ref AS cof ON cof.ForTable = cond.ConditionTable AND cof.ForField = cond.ConditionField INNER JOIN
                         dbo.ref_reference AS ref ON ref.ref_categories_UID = cof.LookupField INNER JOIN
                         dbo.ref_item AS item ON item.UID = ref.ref_item_UID INNER JOIN
                         dbo.sys_localisation AS loc ON loc.UID = item.sys_localisation_uid
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
         Begin Table = "cond"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 217
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cof"
            Begin Extent = 
               Top = 6
               Left = 255
               Bottom = 135
               Right = 425
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ref"
            Begin Extent = 
               Top = 6
               Left = 463
               Bottom = 135
               Right = 649
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "loc"
            Begin Extent = 
               Top = 6
               Left = 687
               Bottom = 118
               Right = 857
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "item"
            Begin Extent = 
               Top = 6
               Left = 895
               Bottom = 118
               Right = 1087
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
      Begin ColumnWidths = 13
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
      End
   End
   Begin CriteriaPane = 
      Begin Co' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_cond_value_full_list'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'lumnWidths = 11
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_cond_value_full_list'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_cond_value_full_list'
GO

