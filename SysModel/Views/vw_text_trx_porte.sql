USE [Configurateur]
GO

/****** Object:  View [dbo].[vw_text_trx_porte]    Script Date: 2026-04-20 11:25:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_text_trx_porte]
AS
SELECT        prj.Projet,
                             (SELECT        TOP (1) OrderNum
                               FROM            [SQL02-NORBEC].NorbecCustom.dbo.orderhed AS oh
                               WHERE        (ShortChar02 = prj.Projet COLLATE SQL_Latin1_General_CP1_CI_AS)) AS Ordernum, grp.seq_id, 0 AS quoteline, trp.UID, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.porte_type)), '') AS VARCHAR(30)) AS porte_type, trp.id_porte, trp.ouverture_largeur, trp.ouverture_hauteur, 
                         CAST(ISNULL(dbo.fn_get_functional(trp.porte_epaisseur), '') AS VARCHAR(30)) AS porte_epaisseur, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.application)), '') AS VARCHAR(30)) AS Application, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.porte_fini_int)), '') AS VARCHAR(30)) AS porte_fini_int, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.porte_fini_ext)), '') AS VARCHAR(30)) AS porte_fini_ext, CASE WHEN CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            ref_item ite JOIN
                                                          ref_reference ref ON ite.uid = ref.ref_item_uid JOIN
                                                          sys_localisation loc ON loc.uid = ite.sys_localisation_uid
                                 WHERE        ref.uid = (trp.controle1)), '') AS VARCHAR(30)) + CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            ref_item ite JOIN
                                                          ref_reference ref ON ite.uid = ref.ref_item_uid JOIN
                                                          sys_localisation loc ON loc.uid = ite.sys_localisation_uid
                                 WHERE        ref.uid = (trp.controle2)), '') AS VARCHAR(30)) + CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            ref_item ite JOIN
                                                          ref_reference ref ON ite.uid = ref.ref_item_uid JOIN
                                                          sys_localisation loc ON loc.uid = ite.sys_localisation_uid
                                 WHERE        ref.uid = (trp.controle3)), '') AS VARCHAR(30)) + CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            ref_item ite JOIN
                                                          ref_reference ref ON ite.uid = ref.ref_item_uid JOIN
                                                          sys_localisation loc ON loc.uid = ite.sys_localisation_uid
                                 WHERE        ref.uid = (trp.controle4)), '') AS VARCHAR(30)) + CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            ref_item ite JOIN
                                                          ref_reference ref ON ite.uid = ref.ref_item_uid JOIN
                                                          sys_localisation loc ON loc.uid = ite.sys_localisation_uid
                                 WHERE        ref.uid = (trp.controle5)), '') AS VARCHAR(30)) LIKE '%intelligence%' THEN 1 ELSE 0 END AS intelligence, 
                         CAST(ISNULL(dbo.fn_get_functional(trp.sens_ouverture), '') AS VARCHAR(30)) AS sens_ouverture, CAST(ISNULL(dbo.fn_get_functional(trp.penture_balai), '') 
                         AS VARCHAR(30)) AS penture_balai, CAST(ISNULL(dbo.fn_get_functional(trp.seuil_type), '') AS VARCHAR(30)) AS seuil_type, 
                         CAST(ISNULL(dbo.fn_get_functional(trp.plaque_prot_int_fini), '') AS VARCHAR(30)) AS plaque_prot_int_fini, trp.plaque_prot_int_hauteur, 
                         CAST(ISNULL(dbo.fn_get_functional(trp.plaque_prot_ext_fini), '') AS VARCHAR(30)) AS plaque_prot_ext_fini, trp.plaque_prot_ext_hauteur, '1' AS Qte, 'porte' AS Item, 
                         CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.rampe_type)), '') AS VARCHAR(30)) AS rampe_type, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.pentures_type)), '') AS VARCHAR(250)) AS pentures_type, CAST(ISNULL(trp.pentures_qte, 0) AS VARCHAR(30)) AS pentures_qte, 
                         CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.penture_poignee)), '') AS VARCHAR(30)) AS penture_poignee, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.fen_congelateur)), '') AS VARCHAR(30)) + CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.fen_refrigerateur)), '') AS VARCHAR(30)) AS fenetre, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.penture_bas_de_porte_chauffant)), '') AS VARCHAR(30)) + CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.cl_porte_chauffante)), '') AS VARCHAR(30)) AS porte_chauffante, CASE WHEN ISNULL(trp.trx_chambre_uid, 0) 
                         <> 0 THEN '0' ELSE '1' END AS porte_vendue_seule, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.penture_verrou)), '') AS VARCHAR(250)) AS penture_verrou, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.penture_fermoir)), '') AS VARCHAR(250)) + CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.cl_fermoir)), '') AS VARCHAR(250)) AS fermoir, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.penture_pedale)), '') AS VARCHAR(250)) AS penture_pedale, CASE WHEN CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            ref_item ite JOIN
                                                          ref_reference ref ON ite.uid = ref.ref_item_uid JOIN
                                                          sys_localisation loc ON loc.uid = ite.sys_localisation_uid
                                 WHERE        ref.uid = (trp.controle1)), '') AS VARCHAR(250)) + CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            ref_item ite JOIN
                                                          ref_reference ref ON ite.uid = ref.ref_item_uid JOIN
                                                          sys_localisation loc ON loc.uid = ite.sys_localisation_uid
                                 WHERE        ref.uid = (trp.controle2)), '') AS VARCHAR(250)) + CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            ref_item ite JOIN
                                                          ref_reference ref ON ite.uid = ref.ref_item_uid JOIN
                                                          sys_localisation loc ON loc.uid = ite.sys_localisation_uid
                                 WHERE        ref.uid = (trp.controle3)), '') AS VARCHAR(250)) + CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            ref_item ite JOIN
                                                          ref_reference ref ON ite.uid = ref.ref_item_uid JOIN
                                                          sys_localisation loc ON loc.uid = ite.sys_localisation_uid
                                 WHERE        ref.uid = (trp.controle4)), '') AS VARCHAR(250)) + CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            ref_item ite JOIN
                                                          ref_reference ref ON ite.uid = ref.ref_item_uid JOIN
                                                          sys_localisation loc ON loc.uid = ite.sys_localisation_uid
                                 WHERE        ref.uid = (trp.controle5)), '') AS VARCHAR(250)) LIKE '%interrupteur%' THEN 1 ELSE 0 END AS interrupteur, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.controle1)), '') AS VARCHAR(250)) AS controle1, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.controle2)), '') AS VARCHAR(250)) AS controle2, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.controle3)), '') AS VARCHAR(250)) AS controle3, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.controle4)), '') AS VARCHAR(250)) AS controle4, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.controle5)), '') AS VARCHAR(250)) AS controle5, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.cl_fermeture)), '') AS VARCHAR(30)) AS cl_fermeture, CAST(ISNULL
                             ((SELECT        loc.fr
                                 FROM            dbo.ref_item AS ite INNER JOIN
                                                          dbo.ref_reference AS ref ON ite.UID = ref.ref_item_UID INNER JOIN
                                                          dbo.sys_localisation AS loc ON loc.UID = ite.sys_localisation_uid
                                 WHERE        (ref.UID = trp.valve_type)), '') AS VARCHAR(30)) AS valve_type, ISNULL(trp.valve_qte, 0) AS valve_qte, dbo.fn_get_functional(trp.cadre_epaisseur) 
                         AS cadre_epaisseur
FROM            dbo.trx_porte AS trp INNER JOIN
                         dbo.trx_project AS prj ON prj.UID = trp.trx_project_UID INNER JOIN
                         dbo.trx_groupe AS grp ON grp.UID = trp.trx_groupe_UID LEFT OUTER JOIN
                         dbo.trx_chambre AS ch ON ch.UID = trp.trx_chambre_UID
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
         Begin Table = "trp"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 298
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "prj"
            Begin Extent = 
               Top = 6
               Left = 336
               Bottom = 135
               Right = 506
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "grp"
            Begin Extent = 
               Top = 6
               Left = 544
               Bottom = 135
               Right = 737
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ch"
            Begin Extent = 
               Top = 6
               Left = 775
               Bottom = 135
               Right = 993
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
      Begin ColumnWidths = 44
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
         Width = 1500' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_text_trx_porte'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'
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
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_text_trx_porte'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_text_trx_porte'
GO

