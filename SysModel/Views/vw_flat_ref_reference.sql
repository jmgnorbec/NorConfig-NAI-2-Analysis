USE [Configurateur]
GO

/****** Object:  View [dbo].[vw_flat_ref_reference]    Script Date: 2026-04-20 11:15:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_flat_ref_reference]
AS
SELECT        dbo.ref_reference.UID, ite.partnum, ite.UID AS ref_item_uid, dbo.ref_categories.UID AS ref_categories_UID, dbo.ref_categories.code, typ.nom AS type, 
                         dbo.sys_localisation.UID AS sys_localisation_UID, dbo.sys_localisation.en, dbo.sys_localisation.fr, ite.represent_empty, ite.functional_value
FROM            dbo.ref_reference INNER JOIN
                         dbo.ref_categories ON dbo.ref_categories.UID = dbo.ref_reference.ref_categories_UID INNER JOIN
                         dbo.ref_item AS ite ON ite.UID = dbo.ref_reference.ref_item_UID INNER JOIN
                         dbo.sys_localisation ON dbo.sys_localisation.UID = ite.sys_localisation_uid LEFT OUTER JOIN
                         dbo.ref_type AS typ ON typ.UID = dbo.ref_categories.ref_type_UID
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
         Begin Table = "ref_reference"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "ref_categories"
            Begin Extent = 
               Top = 6
               Left = 262
               Bottom = 118
               Right = 432
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ite"
            Begin Extent = 
               Top = 6
               Left = 678
               Bottom = 268
               Right = 870
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sys_localisation"
            Begin Extent = 
               Top = 120
               Left = 262
               Bottom = 232
               Right = 432
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "typ"
            Begin Extent = 
               Top = 6
               Left = 470
               Bottom = 101
               Right = 640
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
         Alias = 90' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_flat_ref_reference'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'0
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_flat_ref_reference'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_flat_ref_reference'
GO

