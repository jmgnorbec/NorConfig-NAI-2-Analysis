USE [Configurateur]
GO

/****** Object:  View [dbo].[vw_eli5_sys_field_change_impact]    Script Date: 2026-04-20 10:18:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_eli5_sys_field_change_impact]
AS
SELECT        'Le champ [' + fie.ForField + '] de la table [' + fie.ForTable + '] est impacté par un changement au champ: [' + con.ConditionField + '] de [' + con.ConditionTable + ']. ' + 'Impact possible: '
                          + rty.text + ' (' + ISNULL(fcr.flat_val, '') + ')' + ' Par la condition: ' + cty.descr_fr + ' (' + cli.flat_val + ') du limitateur: ' + lim.Nom AS explication, con.UID, 
                         con.sys_limitator_UID, con.AndOr, con.ConditionTable, con.ConditionField, con.ConditionType, con.ConditionValue, cty.UID AS cond_type_uid, cty.descr_fr, 
                         cty.desc_en, cty.prog, cty.use_cond_value_list, cli.sys_condition_UID, cli.flat_list, cli.flat_val, lim.UID AS lim_uid, lim.Nom, lim.ConditionText, lim.ConditionResult, 
                         lim.sys_limitator_result_type_uid, sfl.UID AS sfl_uid, sfl.sys_field_ref_UID, sfl.sys_limitator_UID AS Expr4, fie.UID AS fie_uid, fie.ForTable, fie.ForField, 
                         fie.LookupTable, fie.LookupField, fie.DefFromTable, fie.DefFromField, fie.Description, fie.[DefCondition?], fie.NoDesignDoc, rty.uid AS rty_uid, rty.text, rty.code, 
                         rty.use_result_list, fcr.sys_limitator_uid AS Expr8, fcr.flat_list AS result_flat_list, fcr.flat_val AS result_flat_val
FROM            dbo.sys_limitator AS lim LEFT OUTER JOIN
                         dbo.sys_condition AS con ON lim.UID = con.sys_limitator_UID LEFT OUTER JOIN
                         dbo.sys_condition_type AS cty ON cty.UID = con.ConditionType LEFT OUTER JOIN
                         dbo.vw_flat_cond_list AS cli ON con.UID = cli.sys_condition_UID LEFT OUTER JOIN
                         dbo.sys_field_limitator AS sfl ON sfl.sys_limitator_UID = lim.UID LEFT OUTER JOIN
                         dbo.sys_field_ref AS fie ON fie.UID = sfl.sys_field_ref_UID LEFT OUTER JOIN
                         dbo.sys_limitator_result_type AS rty ON rty.uid = lim.sys_limitator_result_type_uid LEFT OUTER JOIN
                         dbo.vw_flat_cond_results AS fcr ON fcr.sys_limitator_uid = lim.UID
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
         Begin Table = "con"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 217
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cty"
            Begin Extent = 
               Top = 6
               Left = 255
               Bottom = 135
               Right = 447
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cli"
            Begin Extent = 
               Top = 6
               Left = 485
               Bottom = 118
               Right = 670
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "lim"
            Begin Extent = 
               Top = 6
               Left = 708
               Bottom = 135
               Right = 947
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sfl"
            Begin Extent = 
               Top = 6
               Left = 985
               Bottom = 118
               Right = 1164
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "fie"
            Begin Extent = 
               Top = 120
               Left = 485
               Bottom = 249
               Right = 655
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "rty"
            Begin Extent = 
               Top = 120
               Left = 985
               Bottom = 249
               Right = 1155
            End
            DisplayFlags = 280
            TopColumn = 0
  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_eli5_sys_field_change_impact'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'       End
         Begin Table = "fcr"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 250
               Right = 217
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
      Begin ColumnWidths = 43
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_eli5_sys_field_change_impact'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_eli5_sys_field_change_impact'
GO


