get_dge <- function(x){
  dge <- DGEList(
    counts = assay(x, "counts"),
    genes = rowData(x)
  )
  dge <- calcNormFactors(dge)
  dge
}

ggplot_genotype <- function(x){
  ggplot(as.data.frame(colData(x)), aes(y = assigned_gene_prop, x = genotype_factor)) +
    geom_boxplot() + geom_jitter(width=0.15,alpha=0.5)+
    theme_bw(base_size = 20) +
    ylab("Assigned Gene Prop") +
    xlab("Genotype Group")+
    scale_x_discrete(guide = guide_axis(n.dodge=3))

}

get_genotype_id <- function(x){
  unique(paste(x$genotype_factor,x$sra_attribute.genotype))

}


make_model_age <- function(x){
  mod <- model.matrix(~   sra_attribute.age +sra_attribute.genotype + sra_attribute.tissue,
                      data = colData(x)
  )
  mod
}
make_model_genotype <- function(x){
  mod <- model.matrix(~ sra_attribute.genotype +  sra_attribute.age + sra_attribute.tissue,
                      data = colData(x)
  )
  mod
}

get_de_results <- function(x, eb_results){
  de_results <- topTable(
    eb_results,
    coef = 2,
    number = nrow(x),
    sort.by = "none"
  )
  de_results
}




make_volcano <- function(FC,p,de_results){
  keyvals <- rep('grey75', nrow(de_results))
  names(keyvals) <- rep('NS', nrow(de_results))

  keyvals[which(abs(de_results$logFC  ) > FC & de_results$P.Value > p)] <- 'grey50'
  names(keyvals)[which(abs(de_results$logFC) > FC & de_results$P.Value > p)] <- 'log2FoldChange'

  keyvals[which(abs(de_results$logFC  ) < FC & de_results$P.Value < p)] <- 'grey25'
  names(keyvals)[which(abs(de_results$logFC  ) < FC & de_results$P.Value < p)] <- '-Log10Q'

  keyvals[which(de_results$logFC < -FC & de_results$P.Value < p)] <- 'blue2'
  names(keyvals)[which(de_results$logFC  < -FC & de_results$P.Value < p)] <- 'Signif. down-regulated'

  keyvals[which(de_results$logFC > FC & de_results$P.Value < p)] <- 'red2'
  names(keyvals)[which(de_results$logFC > FC & de_results$P.Value < p)] <- 'Signif. up-regulated'

  unique(keyvals)
  unique(names(keyvals))

  EnhancedVolcano(de_results,
                  lab = de_results$gene_name,
                  x = 'logFC',
                  y = 'adj.P.Val',
                  title = 'Volcano plot',
                  pCutoff = p,
                  FCcutoff = FC,
                  pointSize = 2.5,
                  labSize = 4.5,
                  colCustom = keyvals,
                  colAlpha = 0.75,
                  legendPosition = 'right',
                  legendLabSize = 15,
                  legendIconSize = 5.0,
                  drawConnectors = TRUE,
                  widthConnectors = 0.5,
                  colConnectors = 'grey50',
                  gridlines.major = TRUE,
                  gridlines.minor = FALSE,
                  border = 'partial')
}



make_MA_plot <- function(de_results, eb_results, p, FC){
  de_results.filt <- de_results[de_results$adj.P.Val < p,]
  all_DEgenes <- de_results.filt[abs(de_results.filt$logFC)>FC,]

  DEgenes <- rownames(all_DEgenes)
  limma::plotMA(eb_results, coef = 2, status = rownames(eb_results$lods) %in% DEgenes, legend = FALSE,
                main = "MA plot")
  legend("bottomright", c("DE genes", "Not DE genes"), fill = c("red", "black"), inset = 0.01)
}



make_heatmap <- function(x, exprs_heatmap ){

  ## Creemos una tabla con información de las muestras
  ## y con nombres de columnas más amigables
  df <- as.data.frame(colData(x)[, c( "age_class","sra_attribute.genotype","sra_attribute.tissue")])
  colnames(df) <- c( "Age", "Genotype", "Tissue")



  ## Hagamos un heatmap
  pheatmap(
    exprs_heatmap,
    title='aaaah',
    cluster_rows = TRUE,
    cluster_cols = TRUE,
    show_rownames = TRUE,
    show_colnames = FALSE,
    annotation_col = df
  )

  pheatmap(
    exprs_heatmap,
    cluster_rows = TRUE,
    cluster_cols = TRUE,
    show_rownames = TRUE,
    show_colnames = FALSE,
    annotation_col = df,
    scale = "row"
  )
  df
}
