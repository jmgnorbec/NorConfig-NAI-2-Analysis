USE [Configurateur]
GO

/****** Object:  Table [dbo].[ref_item]    Script Date: 2026-04-20 10:23:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ref_item](
	[UID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[partnum] [nvarchar](50) NULL,
	[sys_localisation_uid] [int] NOT NULL,
	[prix_vendant] [decimal](18, 4) NULL,
	[prix_supp] [decimal](18, 4) NULL,
	[prix_coutant] [decimal](18, 4) NULL,
	[markup] [decimal](18, 4) NULL,
	[comment] [nvarchar](max) NULL,
	[udm] [int] NULL,
	[price_per] [decimal](18, 4) NULL,
	[represent_empty] [bit] NULL,
	[functional_value] [nvarchar](50) NULL,
	[image_on_plan] [nvarchar](50) NULL,
	[ref_partnum] [nvarchar](50) NULL,
	[comment_finance] [nvarchar](250) NULL,
	[cou_mod] [decimal](18, 4) NULL,
	[cou_fgf] [decimal](18, 4) NULL,
 CONSTRAINT [ref_item_PK] PRIMARY KEY CLUSTERED 
(
	[UID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[ref_item] ADD  CONSTRAINT [DF_ref_item_represent_empty]  DEFAULT ((0)) FOR [represent_empty]
GO

ALTER TABLE [dbo].[ref_item]  WITH CHECK ADD  CONSTRAINT [ref_item_sys_localisation_FK] FOREIGN KEY([sys_localisation_uid])
REFERENCES [dbo].[sys_localisation] ([UID])
GO

ALTER TABLE [dbo].[ref_item] CHECK CONSTRAINT [ref_item_sys_localisation_FK]
GO

