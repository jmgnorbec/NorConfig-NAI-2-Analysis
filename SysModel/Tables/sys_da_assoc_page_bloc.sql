USE [Configurateur]
GO

/****** Object:  Table [dbo].[sys_da_assoc_page_bloc]    Script Date: 2026-04-20 10:30:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[sys_da_assoc_page_bloc](
	[sys_da_page_uid] [int] NOT NULL,
	[sys_da_bloc_uid] [int] NOT NULL,
	[seqno] [int] NOT NULL,
	[condition] [text] NULL,
	[pos_style] [nvarchar](250) NULL,
	[largeur] [decimal](28, 4) NOT NULL,
	[hauteur] [decimal](28, 4) NOT NULL,
 CONSTRAINT [PK_sys_da_assoc_page_bloc] PRIMARY KEY CLUSTERED 
(
	[sys_da_page_uid] ASC,
	[sys_da_bloc_uid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[sys_da_assoc_page_bloc] ADD  CONSTRAINT [DF_sys_da_ass_page_bloc_seqno]  DEFAULT ((1)) FOR [seqno]
GO

ALTER TABLE [dbo].[sys_da_assoc_page_bloc] ADD  CONSTRAINT [DF_sys_da_assoc_page_bloc_width]  DEFAULT ((0)) FOR [largeur]
GO

ALTER TABLE [dbo].[sys_da_assoc_page_bloc] ADD  CONSTRAINT [DF_sys_da_assoc_page_bloc_heigth]  DEFAULT ((0)) FOR [hauteur]
GO

ALTER TABLE [dbo].[sys_da_assoc_page_bloc]  WITH CHECK ADD  CONSTRAINT [FK_sys_da_assoc_page_bloc_sys_da_bloc] FOREIGN KEY([sys_da_bloc_uid])
REFERENCES [dbo].[sys_da_bloc] ([UID])
GO

ALTER TABLE [dbo].[sys_da_assoc_page_bloc] CHECK CONSTRAINT [FK_sys_da_assoc_page_bloc_sys_da_bloc]
GO

ALTER TABLE [dbo].[sys_da_assoc_page_bloc]  WITH CHECK ADD  CONSTRAINT [FK_sys_da_assoc_page_bloc_sys_da_page] FOREIGN KEY([sys_da_page_uid])
REFERENCES [dbo].[sys_da_page] ([UID])
GO

ALTER TABLE [dbo].[sys_da_assoc_page_bloc] CHECK CONSTRAINT [FK_sys_da_assoc_page_bloc_sys_da_page]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'html style terminology' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'sys_da_assoc_page_bloc', @level2type=N'COLUMN',@level2name=N'pos_style'
GO

