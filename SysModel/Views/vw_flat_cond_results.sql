USE [Configurateur]
GO

/****** Object:  View [dbo].[vw_flat_cond_results]    Script Date: 2026-04-20 11:13:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_flat_cond_results]
AS
SELECT        UID as sys_limitator_uid, LEFT(flat_list, LEN(flat_list) - 1) AS flat_list
, 
(CASE 
WHEN lim.sys_limitator_result_type_uid='5' THEN lim.ConditionResult
ELSE LEFT(flat_val, LEN(flat_val) - 2) 
END) AS flat_val
FROM   sys_limitator lim    left join     (SELECT        extern.sys_limitator_UID,
                                                        (SELECT        loc.fr + ','
                                                          FROM            sys_cond_result AS intern JOIN
                                                                                    ref_reference ref ON ref.uid = intern.ResultValue JOIN
                                                                                    ref_item item ON item.uid = ref.ref_item_UID JOIN
                                                                                    sys_localisation loc ON loc.uid = item.sys_localisation_uid
                                                          WHERE        extern.sys_limitator_UID = intern.sys_limitator_UID FOR XML PATH('')) AS flat_list, '''' +
                                                        (SELECT        CAST(intern.ResultValue AS varchar) + ''','''
                                                          FROM            sys_cond_result AS intern
                                                          WHERE        extern.sys_limitator_UID = intern.sys_limitator_UID FOR XML PATH('')) AS flat_val
                          FROM            sys_cond_result AS extern
						  
                          GROUP BY sys_limitator_UID) AS limitator_result
						    on lim.uid=sys_limitator_UID
							
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
      PaneHidden = 
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_flat_cond_results'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_flat_cond_results'
GO

