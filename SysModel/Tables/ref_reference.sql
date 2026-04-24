USE [Configurateur]
GO

/****** Object:  Table [dbo].[ref_reference]    Script Date: 2026-04-20 10:25:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ref_reference](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ref_categories_UID] [int] NOT NULL,
	[ref_item_UID] [int] NULL,
	[prix_vendant] [decimal](18, 4) NULL,
	[prix_coutant] [decimal](18, 4) NULL,
	[prix_supp] [decimal](18, 4) NULL,
	[markup] [decimal](18, 4) NULL,
	[modulr_map] [nvarchar](50) NOT NULL,
	[modulr_ref_item_UID] [int] NULL,
	[inv_key] [nvarchar](150) NULL,
	[inv_value] [nvarchar](250) NULL,
 CONSTRAINT [reference_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ref_reference] ADD  CONSTRAINT [DF_ref_reference_modulr_map]  DEFAULT ('block') FOR [modulr_map]
GO

ALTER TABLE [dbo].[ref_reference] ADD  CONSTRAINT [DF_ref_reference_inv_key]  DEFAULT ('') FOR [inv_key]
GO

ALTER TABLE [dbo].[ref_reference] ADD  CONSTRAINT [DF_ref_reference_inv_value]  DEFAULT ('') FOR [inv_value]
GO

ALTER TABLE [dbo].[ref_reference]  WITH CHECK ADD  CONSTRAINT [ref_reference_ref_item_FK] FOREIGN KEY([ref_item_UID])
REFERENCES [dbo].[ref_item] ([UID])
GO

ALTER TABLE [dbo].[ref_reference] CHECK CONSTRAINT [ref_reference_ref_item_FK]
GO

ALTER TABLE [dbo].[ref_reference]  WITH CHECK ADD  CONSTRAINT [reference_ref_categories_FK] FOREIGN KEY([ref_categories_UID])
REFERENCES [dbo].[ref_categories] ([UID])
GO

ALTER TABLE [dbo].[ref_reference] CHECK CONSTRAINT [reference_ref_categories_FK]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Qualify mapping to modular: block - no mapping possible for quote   map - map feature using modulr_ref_item_UID   ignore - exclude feature from modular quote' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ref_reference', @level2type=N'COLUMN',@level2name=N'modulr_map'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'En reference a NorLogic.dbo.inv_GroupDefaultParameter Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ref_reference', @level2type=N'COLUMN',@level2name=N'inv_key'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'En reference a NorLogic.dbo.inv_GroupDefaultParameter Value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ref_reference', @level2type=N'COLUMN',@level2name=N'inv_value'
GO

