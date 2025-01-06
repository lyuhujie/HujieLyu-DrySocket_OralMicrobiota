[TOC]

# 易扩增子EasyAmplicon

    # 作者 Authors: 刘永鑫(Yong-Xin Liu), 陈同(Tong Chen)等
    # 版本 Version: v1.20
    # 更新 Update: 2023-10-13
    # 系统要求 System requirement: Windows 10+ / Mac OS 10.12+ / Ubuntu 20.04+
    # 引文 Reference: Liu, et al. 2023. EasyAmplicon: An easy-to-use, open-source, reproducible, and community-based
    # pipeline for amplicon data analysis in microbiome research. iMeta 2: e83. https://doi.org/10.1002/imt2.83
    # control+c就是终止命令，终止正在运行的命令
    # control+z可以返回上一步
    # control + shift + C添加注释或去除注释
    # 设置工作(work directory, wd)和软件数据库(database, db)目录
    # 添加环境变量，并进入工作目录 Add environmental variables and enter work directory
    # **每次打开Rstudio必须运行下面4行 Run it**，可选替换${db}为EasyMicrobiome安装位置
   
   
    # 本地版本
    wd=/c/16S
    db=/c/EasyMicrobiome-master
    PATH=$PATH:${db}/win
    cd ${wd}
    
    #  linux版本
    source /data/meta/.bashrc
    db=/data7/lvhujie/db_old/EasyMicrobiome
    DB=/db
    # 设置工作目录work directory(wd)，如meta
    # wd=~/EasyMetagenome  cd $wd
    wd=~/oral
    # 创建并进入工作目录
    mkdir -p $wd && cd $wd
    # 创建3个常用子目录：序列，临时文件和结果
    mkdir -p seq temp result
    # 添加分析所需的软件、脚本至环境变量，添加至~/.bashrc中自动加载
    PATH=$soft/bin:$soft/condabin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$db/linux:$db/script:$db:$DB/eggnog:$DB/humann3:$DB/kraken2:$DB/metaphlan4:/data/meta/db/eggnog
    echo $PATH
    
    # wd=/c/EasyAmplicon/EasyAmplicon-master
    # db=/c/EasyMicrobiome/EasyMicrobiome-master
    # PATH=$PATH:${db}/win
    # cd ${wd}




### 作图前重要文件罗列
### 元数据/实验设计 metadata
    result/metadata.txt
### 5.1 生成特征表
    result/raw/otutab.txt
   
### 5.2 物种注释，且/或去除质体和非细菌 Remove plastid and non-Bacteria
    result/raw/otus.sintax
    result/otus.sintax

    # OTU表简单统计 Summary OTUs table
    result/otutab.stat
    #注意最小值、分位数，或查看result/raw/otutab_nonBac.stat中样本详细数据量，用于重采样

# #  换回自己电脑，可以不用服务器
#     # 本地版本
#     wd=/c/16S
#     db=/c/EasyMicrobiome-master
#     PATH=$PATH:${db}/win
#     cd ${wd}
    
    
### 5.3 等量抽样标准化

    # Normlize by subsample
    #使用vegan包进行等量重抽样，输入reads count格式Feature表result/otutab.txt
    #可指定输入文件、抽样量和随机数，输出抽平表result/otutab_rare.txt和多样性alpha/vegan.txt
    # depth 原本是10000
    result/alpha/vegan.txt
    result/otutab_rare.stat
 
  
# 读取txt文件
# Rscript -e 'data <- read.table("otutab_mean.txt", header = TRUE, sep = "\t", stringsAsFactors = FALSE)
# 
# # 获取行数和列数
# nrows <- nrow(data)
# ncols <- ncol(data)
# 
# # 遍历数据，跳过第一行和第一列
# for (i in 1:nrows) {
#   for (j in 2:ncols) {
#     # 尝试将数据转换为数字
#     numeric_value <- suppressWarnings(as.numeric(data[i, j]))
#     # 如果转换成功且不产生NA，则更新为整数值
#     if (!is.na(numeric_value)) {
#       data[i, j] <- as.integer(numeric_value)
#     }
#   }
# }
# 
# # 保存修改后的数据回txt文件
# write.table(data, "otutab_mean_new.txt", sep = "\t", row.names = FALSE, quote = FALSE)'

    # 绘制按照DHI分组的 vegan.txt和otutab_rare_DHI.stat
    Rscript ${db}/script/otutab_rare.R --input result/otutab_mean.txt \
      --depth 0 --seed 1 \
      --normalize result/otutab_rare_DHI.txt \
      --output result/alpha/vegan_DHI.txt
    usearch -otutab_stats result/otutab_rare_DHI.txt \
      -output result/otutab_rare_DHI.stat
    cat result/otutab_rare_DHI.stat


## 6. α多样性 alpha diversity

### 6.1. 计算α多样性 calculate alpha diversity

    # 使用USEARCH计算14种alpha多样性指数(Chao1有错勿用)
    #details in http://www.drive5.com/usearch/manual/alpha_metrics.html
    result/alpha/alpha.txt

### 6.2. 计算稀释丰富度 calculate rarefaction richness

    #稀释曲线：取1%-100%的序列中OTUs数量，每次无放回抽样
    #Rarefaction from 1%, 2% .. 100% in richness (observed OTUs)-method without_replacement https://drive5.com/usearch/manual/cmd_otutab_subsample.html
    result/alpha/alpha_rare.txt

### 6.3. 筛选高丰度菌 Filter by abundance-（画进化树有用，一般一棵树100个分支好）

    #计算各特征的均值，有组再求分组均值，需根据实验设计metadata.txt修改组列名
    #输入文件为feautre表result/otutab.txt，实验设计metadata.txt
    otutab_mean.txt
    
    # 对应不同分组方式的 DHI
    result/otutab_mean_DHI.txt
  
    # 对应不同分组方式的 SE
    result/otutab_mean_SE.txt
  
    # 对应不同分组方式的 pre_med_post
    result/otutab_mean_premedpost.txt
    
    # 对应不同分组方式的 S_H
    result/otutab_mean_S_H.txt
    
    # 对应不同分组方式的 E_med
    otutab_mean_E_med.txt
    
    # 对应不同分组方式的 DHI分组
    result/otutab_mean_DHI.txt
   
    # 对应不同分组方式的，按照Group_dayE分组
    # 这步可以为后面做热图等出数据
    # 需要自己改顺序分组顺序
    otutab_Group_dayE.txt
    
    ## 对beta多样性原始数据进行制作。 
    result/otutab_mean_Group_dayE_beta.txt
    
  
    ##筛选步骤 
    #如以平均丰度>0.1%筛选，可选0.5或0.05，得到每个组的OTU组合
    awk 'BEGIN{OFS=FS="\t"}{if(FNR==1) {for(i=3;i<=NF;i++) a[i]=$i; print "OTU","Group";} \
        else {for(i=3;i<=NF;i++) if($i>0.1) print $1, a[i];}}' \
        result/otutab_mean_S_med.txt > result/alpha/otu_group_exist_S_med.txt
    head result/alpha/otu_group_exist_S_med.txt
    cut -f 2 result/alpha/otu_group_exist_S_med.txt | sort | uniq -c
    
    awk 'BEGIN{OFS=FS="\t"}{if(FNR==1) {for(i=3;i<=NF;i++) a[i]=$i; print "OTU","Group";} \
        else {for(i=3;i<=NF;i++) if($i>0.1) print $1, a[i];}}' \
        result/otutab_mean_S_H.txt > result/alpha/otu_group_exist_S_H.txt

    awk 'BEGIN{OFS=FS="\t"}{if(FNR==1) {for(i=3;i<=NF;i++) a[i]=$i; print "OTU","Group";} \
        else {for(i=3;i<=NF;i++) if($i>0.1) print $1, a[i];}}' \
        result/otutab_mean_E_med.txt > result/alpha/otu_group_exist_E_med.txt

   awk 'BEGIN{OFS=FS="\t"}{if(FNR==1) {for(i=3;i<=NF;i++) a[i]=$i; print "OTU","Group";} \
        else {for(i=3;i<=NF;i++) if($i>0.1) print $1, a[i];}}' \
        result/otutab_mean_Group_dayE.txt > result/alpha/otu_group_exist_Group_dayE.txt
    
   #绘制韦恩图时使用，找每个组的OTU有些什么有多少。
   awk 'BEGIN{OFS=FS="\t"}{if(FNR==1) {for(i=3;i<=NF;i++) a[i]=$i; print "OTU","Group";} \
        else {for(i=3;i<=NF;i++) if($i>0.1) print $1, a[i];}}' \
        result/otutab_mean_DHI.txt > result/alpha/otu_mean_venn_DHI.txt
  
  
   awk 'BEGIN{OFS=FS="\t"}{if(FNR==1) {for(i=3;i<=NF;i++) a[i]=$i; print "OTU","Group";} \
        else {for(i=3;i<=NF;i++) if($i>0.1) print $1, a[i];}}' \
        result/otutab_mean_SE.txt > result/alpha/otu_mean_venn_SE.txt
  
   awk 'BEGIN{OFS=FS="\t"}{if(FNR==1) {for(i=3;i<=NF;i++) a[i]=$i; print "OTU","Group";} \
        else {for(i=3;i<=NF;i++) if($i>0.1) print $1, a[i];}}' \
        result/otutab_mean_premedpost.txt > result/alpha/otu_mean_venn_premedpost.txt
    # 试一试：不同丰度下各组有多少OTU/ASV
    # 可在 http://ehbio.com/test/venn/ 中绘图并显示各组共有和特有维恩或网络图
    # 也可在 http://www.ehbio.com/ImageGP 绘制Venn、upSetView和Sanky


## 7. β多样性 Beta diversity
    # 用于构建进化树
    result/otus.tree
    #生成5种距离矩阵：bray_curtis, euclidean, jaccard, manhatten, unifrac
    usearch -beta_div result/otutab_mean_Group_dayE_beta.txt -tree result/otus.tree \
      -filename_prefix result/beta/

    #可能会需要
    result/otus2.tree
    #生成5种距离矩阵：bray_curtis, euclidean, jaccard, manhatten, unifrac
    usearch -beta_div result/otutab_rare.txt -tree result/otus2.tree \
      -filename_prefix result/beta2/

## 8. 物种注释分类汇总
    result/taxonomy2.txt
    
    #生成物种表格OTU/ASV中空白补齐为Unassigned
    result/taxonomy.txt

    #统计门纲目科属，使用 rank参数 p c o f g，为phylum, class, order, family, genus缩写
    for i in p c o f g;do
      usearch -sintax_summary result/otus.sintax \
      -otutabin result/otutab_rare.txt -rank ${i} \
      -output result/tax/all_sum_${i}.txt
    done
    sed -i 's/(//g;s/)//g;s/\"//g;s/\#//g;s/\/Chloroplast//g' result/tax/all_sum_*.txt
    # 列出所有文件
    wc -l result/tax/all_sum_*.txt
  
    ### 制作首列是分组的物种分类表
    for i in p c o f g;do
      usearch -sintax_summary result/otus.sintax \
      -otutabin result/otutab_Group_dayE.txt -rank ${i} \
      -output result/tax/sum_${i}.txt
    done
    sed -i 's/(//g;s/)//g;s/\"//g;s/\#//g;s/\/Chloroplast//g' result/tax/sum_*.txt
    # 列出所有文件
    wc -l result/tax/sum_*.txt
    
    #根据分组制作物种分类表，DHI，SE，premedpost
    for i in p c o f g;do
      usearch -sintax_summary result/otus.sintax \
      -otutabin result/otutab_mean_DHI.txt -rank ${i} \
      -output result/tax2/DHI_sum_${i}.txt
    done
    sed -i 's/(//g;s/)//g;s/\"//g;s/\#//g;s/\/Chloroplast//g' result/tax2/DHI_sum_*.txt
    # 列出所有文件
    wc -l result/tax2/DHI_sum_*.txt


## 9. 有参定量特征表
    result/gg/otutab.txt
    result/gg/otutab.stat
    
## 10. 空间清理及数据提交
    result/md5sum.txt
    
# R语言多样性和物种组成分析





## 1. Alpha多样性

### 1.1 Alpha多样性箱线图


    # 原始代码
    # 查看帮助
    Rscript ${db}/script/alpha_boxplot.R -h
    # 完整参数，多样性指数可选richness chao1 ACE shannon simpson invsimpson
    Rscript ${db}/script/alpha_boxplot.R --alpha_index richness \
      --input result/alpha/vegan.txt --design result/metadata.txt \
      --group Group --output result/alpha/ \
      --width 89 --height 59
     
    # Figure1.B,C
    # 按State分组    
    # 在otuput后面可以加名字改名。
    Rscript ${db}/script/alpha_boxplot.R --alpha_index richness \
      --input result/alpha/vegan.txt --design result/metadata.txt \
      --group State --output result/alpha2/DHI_new_ \
      --width 240 --height 150 
    
    Rscript ${db}/script/alpha_boxplot.R --alpha_index chao1 \
      --input result/alpha/vegan.txt --design result/metadata.txt \
      --group State --output result/alpha2/DHI_new_ \
      --width 240 --height 150 
      
    
    for i in `head -n1 result/alpha/vegan.txt|cut -f 2-`;do
      Rscript ${db}/script/alpha_boxplot.R --alpha_index ${i} \
        --input result/alpha/vegan.txt --design result/metadata_less.txt \
        --group State --output result/alpha/DHI_new_ \
        --width 240 --height 150
    done
    mv alpha_boxplot_TukeyHSD.txt result/alpha2/
      
      
### 1.2 稀释曲线
    # Figure1.D
    Rscript ${db}/script/alpha_rare_curve.R \
      --input result/alpha/alpha_rare.txt --design result/metadata.txt \
      --group State --output result/alpha2/DHI_new \
      --width 240 --height 150

### 1.3 多样性维恩图
    # 三组比较:-f输入文件,-a/b/c/d/g分组名,-w/u为宽高英寸,-p输出文件名后缀
    # 如需按照分组进行绘制venn图，需要分组后的otu_mean.txt文件。
    # 文件制作在467, 577行。
    
    # Figure1.E
    bash ${db}/script/sp_vennDiagram.sh \
      -f result/alpha/otu_mean_venn_DHI.txt \
      -a H -b I -c D  \
      -w 3 -u 3 \
      -p DHI_new
      
    
### Figure3.A alpha多样性部分见 result/alpha2/boxplot+violin.Rmd 脚本      
      
      
      
      
      
## 2. Beta多样性
### 2.2 主坐标分析PCoA

    # 输入文件，选择分组，输出文件，图片尺寸mm，统计见beta_pcoa_stat.txt
    # 输入文件是新设计的metadata_GroupE.txt，或者temp/group.txt
    # R语言不好做，可以用网站。更快
    mkdir -p result/beta2/
    mkdir -p result/beta2/pcoa/
    mkdir -p result/beta2/pcoa/bray_curtis/
    mkdir -p result/beta2/pcoa/euclidean/
    mkdir -p result/beta2/pcoa_new/
    mkdir -p result/beta2/pcoa/bray_curtis_figure_new/
    # 按照对应分组，分析两个分组中所有样本的PCoA。
  
  
    ## Figure3.A
    ## 所需的metadata文件用form2stamp.rmd脚本制作。
    for i in  HSpre_HSmed_HSpost DSmed_ISmed_HSmed DSpre_DGpre;do
    Rscript ${db}/script/beta_pcoa.R \
      --input result/beta2/bray_curtis.txt --design result/beta2/metadata_${i}_p.txt \
      --group Group_dayE --label FALSE --width 89 --height 59 \
      --output result/beta2/pcoa/bray_curtis_figure_new/bray_curtis.pcoa_${i}.pdf
    done  
    mv beta_pcoa_stat.txt result/beta2/pcoa/bray_curtis_figure_new/

    # 其他分组
    # for i in DSpre_DGpre HSpre_HGpre ISpre_IGpre DSmed_DEmed HSmed_HEmed ISmed_IEmed DSpost_DEpost HSpost_HEpost ISpost_IEpost;do
    # Rscript ${db}/script/beta_pcoa.R \
    #   --input result/beta2/bray_curtis.txt --design result/beta2/metadata_${i}_p.txt \
    #   --group Group_dayE --label FALSE --width 89 --height 59 \
    #   --output result/beta2/pcoa/bray_curtis_new/bray_curtis.pcoa_${i}.pdf
    # done  
    # mv beta_pcoa_stat.txt result/beta2/pcoa/bray_curtis_new/ 
    
### 2.3 限制性主坐标分析CPCoA
    mkdir -p result/beta2/cpcoa/
    mkdir -p result/beta2/cpcoa/bray_curtis/
    mkdir -p result/beta2/cpcoa/euclidean/

    ## Figure1.F
    Rscript ${db}/script/beta_cpcoa.R \
      --input result/beta2/bray_curtis.txt --design result/beta2/metadata.txt \
      --group State --width 89 --height 59 \
      --output result/beta2/cpcoa/bray_curtis.cpcoa_22.pdf
      
      
      
## 3. 物种组成Taxonomy

### 3.1 堆叠柱状图Stackplot
    # 以门(p)水平为例，结果包括output.sample/group.pdf两个文件
    
    # Figure2.B,C
    # 主图是用ImageGP生成
    Rscript ${db}/script/tax_stackplot.R -h
    Rscript ${db}/script/tax_stackplot.R \
      --input result/tax/all_sum_p.txt --design result/metadata.txt \
      --group State --color Paired --legend 12 --width 189 --height 119 \
      --output result/tax/New_new_sum_p.stackplot
     
    Rscript ${db}/script/tax_stackplot.R \
      --input result/tax/all_sum_g.txt --design result/metadata.txt \
      --group State --color Paired --legend 12 --width 189 --height 119 \
      --output result/tax/New_new_sum_g.stackplot
  
      
    # # 批量绘制输入包括p/c/o/f/g共5级
    # for i in p c o f g; do
    # Rscript ${db}/script/tax_stackplot.R \
    #   --input result/tax/sum_${i}.txt --design result/metadata.txt \
    #   --group Group --output result/tax/sum_${i}.stackplot \
    #   --legend 8 --width 89 --height 59; done


  

# 24、差异比较

## 1. R语言差异分析
### 1.4 曼哈顿图


    # Figure3.B
    # i差异比较结果,t物种注释,p图例,w宽,v高,s字号,l图例个数最大值
    # 图例显示不图，可增加高度v为119+即可，后期用AI拼图
    compare="HSpre-DSpre"
    bash ${db}/script/compare_manhattan.sh -i result/compare/CP_new/${compare}.txt \
       -t result/taxonomy.txt \
       -p result/tax/all_sum_p.txt \
       -w 200 -v 85 -s 4 -l 15 \
       -o result/compare/CP_new/${compare}.manhattan.p.new.pdf
    # 上图只有6个门，切换为纲c和-L Class展示细节
    bash ${db}/script/compare_manhattan.sh -i result/compare/CP_new/${compare}.txt \
       -t result/taxonomy.txt \
       -p result/tax/all_sum_c.txt \
       -w 200 -v 85 -s 4 -l 15 -L Class \
       -o result/compare/CP_new/${compare}.manhattan.c.pdf
    # 显示完整图例，再用AI拼图
    bash ${db}/script/compare_manhattan.sh -i result/compare/CP_new/${compare}.txt \
       -t result/taxonomy.txt \
       -p result/tax/all_sum_g.txt \
       -w 200 -v 85 -s 4 -l 15 -L Genus \
       -o result/compare/CP_new/${compare}.manhattan.g.legend.new.pdf


    # # 图片有问题可以单个修改
    # compare="DSmed-HSmed"
    # bash ${db}/script/compare_manhattan.sh -i result/compare/CP_edgeR/${compare}.txt \
    #    -t result/taxonomy.txt \
    #    -p result/tax/all_sum_c.txt \
    #    -w 200 -v 98 -s 4 -l 15 -L Class\
    #    -o result/compare/CP_edgeR/${compare}.manhattan.p.pdf
    # 
    # # for 循环批量出图，edgeR  "HGpre-DGpre" "HSpre-DSpre" "HSmed-DSmed" "HEmed-DEmed" "HSpost-DSpost" "HEpost-DEpost"
    #  for i in "HGpre-DGpre" "HSpre-DSpre" "HSmed-DSmed" "HEmed-DEmed" "HSpost-DSpost" "HEpost-DEpost";do
    #   bash ${db}/script/compare_manhattan.sh -i result/compare/CP_new/${i}.txt \
    #     -t result/taxonomy.txt \
    #     -p result/tax/all_sum_c.txt \
    #     -w 200 -v 85 -s 4 -l 10 -L Class \
    #     -o result/compare/CP_new/${i}.manhattan.c.legend.pdf
    #  done
    # 
    # # 按照属水平绘图, edgeR  "HGpre-DGpre" "HSpre-DSpre" "HSmed-DSmed" "HEmed-DEmed" "HSpost-DSpost" "HEpost-DEpost"
    # for i in "HGpre-DGpre" "HSpre-DSpre" "HSmed-DSmed" "HEmed-DEmed" "HSpost-DSpost" "HEpost-DEpost";do
    #   bash ${db}/script/compare_manhattan.sh -i result/compare/CP_new/${i}.txt \
    #     -t result/taxonomy.txt \
    #     -p result/tax/all_sum_g.txt \
    #     -w 200 -v 85 -s 4 -l 15 -L Genus \
    #     -o result/compare/CP_new/${i}.manhattan.g.legend.pdf
    #  done
   
    

## 2. STAMP输入文件准备

### 2.1 生成输入文件

    Rscript ${db}/script/format2stamp.R -h
    mkdir -p result/stamp
    Rscript ${db}/script/format2stamp.R --input result/otutab.txt \
      --taxonomy result/taxonomy.txt --threshold 0.01 \
      --output result/stamp/tax
    # 可选Rmd文档见result/format2stamp.Rmd
    # 想要数据少一些可以改小0.01成0.1
    

### 2.2 绘制扩展柱状图和表



    # Figure3.C
    mkdir -p result/stamp/st_family/
    mkdir -p result/stamp/st_genus/
    mkdir -p result/stamp/st_genus_new/
    mkdir -p result/stamp/st_family_new/
  
    compare="HSpre-DSpre"
    # 选择方法 wilcox/t.test/edgeR、pvalue和fdr和输出目录
    # method 也可以换。wilcox, t.test。估计edgeR也行一般都是log2。log10很少
    # 替换ASV(result/otutab.txt)为属(result/tax/sum_g.txt
    Rscript ${db}/script/compare_stamp.R \
      --input result/stamp/tax_6Genus.txt --metadata result/metadata.txt \
      --group Group_dayE --compare ${compare} --threshold 0.1 \
      --method "t.test" --pvalue 0.05 --fdr "none" \
      --width 189 --height 180 \
      --output result/stamp/st_genus_new/new_${compare}
    
    # 循环比较 t.test genus
    for i in "HGpre-DGpre" "HSpre-DSpre" "HSmed-DSmed" "HEmed-DEmed" "HSpost-DSpost" "HEpost-DEpost";do
    Rscript ${db}/script/compare_stamp.R \
      --input result/stamp/tax_6Genus.txt --metadata result/metadata.txt \
      --group Group_dayE --compare ${i} --threshold 0.1 \
      --method "t.test" --pvalue 0.05 --fdr "none" \
      --width 189 --height 180 \
      --output result/stamp/st_genus_new/new_${i}
    done
  

# 31、功能预测
      
### PICRUSt 2.0
    
    # 软件安装见附录6. PICRUSt环境导出和导入

    # (可选)PICRUSt2(Linux/Windows下Linux子系统，要求>16GB内存)
    # 安装参考附录5的方式直接下载安装包并解压即可使用
    
    # Linux中加载conda环境
    conda activate picrust2
    # 进入工作目录，服务器要修改工作目录
    wd=/mnt/c/16S/result/picrust2
    mkdir -p ${wd} && cd ${wd}
    
    # wd=/mnt/c/16S/result/picrust2/out
    # 服务器上需要换一下
    wd=~/oral/result/picrust2
    mkdir -p ${wd} && cd ${wd}
    
    # 运行流程，内存15.7GB，耗时12m.可以换到服务器24线程
    picrust2_pipeline.py -s ../otus.fa -i ../otutab.txt -o ./out -p 24
    # 添加EC/KO/Pathway注释
    cd out
    add_descriptions.py -i pathways_out/path_abun_unstrat.tsv.gz -m METACYC \
      -o METACYC.tsv
    add_descriptions.py -i EC_metagenome_out/pred_metagenome_unstrat.tsv.gz -m EC \
      -o EC.tsv
    add_descriptions.py -i KO_metagenome_out/pred_metagenome_unstrat.tsv.gz -m KO \
      -o KO.tsv
    # KEGG按层级合并
    cd out
    db=/mnt/c/EasyMicrobiome-master
    # db=/data7/lvhujie/db_old/EasyMicrobiome
    python3 ${db}/script/summarizeAbundance.py \
      -i KO.tsv \
	    -m ${db}/kegg/KO1-4.txt \
	    -c 2,3,4 -s ',+,+,' -n raw \
	    -o KEGG
    # 统计各层级特征数量
    # 解压KO_metagenome_otu/下的压缩包
    zcat KO_metagenome_otu/pred_metagenome_unstrat.tsv.gz > KEGG.KO.txt
    wc -l KEGG*
    
    
    # Figure3.D
    # 可视化见picrust2文件夹中Oral_ggpicrust2.Rmd

## 2. 元素循环FAPROTAX
    ### 作图文件生成
    # 设置工作目录
    wd=/mnt/c/16S/result/faprotax2/
    mkdir -p ${wd} && cd ${wd}
    # 设置脚本目录
    sd=/mnt/c/EasyMicrobiome-master/script/FAPROTAX_1.2.7
  
    ### 1. 软件安装
    # 注：软件已经下载至 EasyMicrobiome/script目录，在qiime2环境下运行可满足依赖关系
    #(可选)下载软件新版本，以1.2.7版为例， 2023/7/14更新数据库
    #wget -c https://pages.uoregon.edu/slouca/LoucaLab/archive/FAPROTAX/SECTION_Download/MODULE_Downloads/CLASS_Latest%20release/UNIT_FAPROTAX_1.2.7/FAPROTAX_1.2.7.zip
    #解压
    #unzip FAPROTAX_1.2.7.zip
    #新建一个python3环境并配置依赖关系，或进入qiime2 python3环境
    conda activate qiime2-2023.7
    # source /home/silico_biotech/miniconda3/envs/qiime2/bin/activate
    #测试是否可运行，弹出帮助即正常工作
    python $sd/collapse_table.py
  

    ### 2. 制作输入OTU表
    #txt转换为biom json格式
    biom convert -i ../otutab_rare_D.txt -o otutab_rare_D.biom --table-type="OTU table" --to-json
    #添加物种注释
    biom add-metadata -i otutab_rare_D.biom --observation-metadata-fp ../taxonomy2.txt \
      -o otutab_rare_tax_D.biom --sc-separated taxonomy \
      --observation-header OTUID,taxonomy
    #指定输入文件、物种注释、输出文件、注释列名、属性列名

    ### 3. FAPROTAX功能预测
    #python运行collapse_table.py脚本、输入带有物种注释OTU表tax.biom、
    #-g指定数据库位置，物种注释列名，输出过程信息，强制覆盖结果，结果文件和细节
    #下载faprotax.txt，配合实验设计可进行统计分析
    #faprotax_report.txt查看每个类别中具体来源哪些OTUs
    python ${sd}/collapse_table.py -i otutab_rare_tax_D.biom \
      -g ${sd}/FAPROTAX.txt \
      --collapse_by_metadata 'taxonomy' -v --force \
      -o faprotax_D.txt -r faprotax_report_D.txt

    ### 4. 制作OTU对应功能注释有无矩阵
    # 对ASV(OTU)注释行，及前一行标题进行筛选
    grep 'ASV_' -B 1 faprotax_report_D.txt | grep -v -P '^--$' > faprotax_report_D.clean
    # faprotax_report_sum.pl脚本将数据整理为表格，位于public/scrit中
    perl ${sd}/../faprotax_report_sum.pl -i faprotax_report_D.clean -o faprotax_report_D
    # 查看功能有无矩阵，-S不换行,control+z退出
    
    less -S faprotax_report_D.mat
   
    ## 分组H
    ### 2. 制作输入OTU表
    #txt转换为biom json格式
    biom convert -i ../otutab_rare_H.txt -o otutab_rare_H.biom --table-type="OTU table" --to-json
    #添加物种注释
    biom add-metadata -i otutab_rare_H.biom --observation-metadata-fp ../taxonomy2.txt \
      -o otutab_rare_tax_H.biom --sc-separated taxonomy \
      --observation-header OTUID,taxonomy
    #指定输入文件、物种注释、输出文件、注释列名、属性列名

    ### 3. FAPROTAX功能预测
    #python运行collapse_table.py脚本、输入带有物种注释OTU表tax.biom、
    #-g指定数据库位置，物种注释列名，输出过程信息，强制覆盖结果，结果文件和细节
    #下载faprotax.txt，配合实验设计可进行统计分析
    #faprotax_report.txt查看每个类别中具体来源哪些OTUs
    python ${sd}/collapse_table.py -i otutab_rare_tax_H.biom \
      -g ${sd}/FAPROTAX.txt \
      --collapse_by_metadata 'taxonomy' -v --force \
      -o faprotax_H.txt -r faprotax_report_H.txt

    ### 4. 制作OTU对应功能注释有无矩阵
    # 对ASV(OTU)注释行，及前一行标题进行筛选
    grep 'ASV_' -B 1 faprotax_report_H.txt | grep -v -P '^--$' > faprotax_report_H.clean
    # faprotax_report_sum.pl脚本将数据整理为表格，位于public/scrit中
    perl ${sd}/../faprotax_report_sum.pl -i faprotax_report_H.clean -o faprotax_report_H
    # 查看功能有无矩阵，-S不换行,control+z退出
    
    less -S faprotax_report_H.mat
    
    
    ## 分组I
    ### 2. 制作输入OTU表
    #txt转换为biom json格式
    biom convert -i ../otutab_rare_I.txt -o otutab_rare_I.biom --table-type="OTU table" --to-json
    #添加物种注释
    biom add-metadata -i otutab_rare_I.biom --observation-metadata-fp ../taxonomy2.txt \
      -o otutab_rare_tax_I.biom --sc-separated taxonomy \
      --observation-header OTUID,taxonomy
    #指定输入文件、物种注释、输出文件、注释列名、属性列名

    ### 3. FAPROTAX功能预测
    #python运行collapse_table.py脚本、输入带有物种注释OTU表tax.biom、
    #-g指定数据库位置，物种注释列名，输出过程信息，强制覆盖结果，结果文件和细节
    #下载faprotax.txt，配合实验设计可进行统计分析
    #faprotax_report.txt查看每个类别中具体来源哪些OTUs
    python ${sd}/collapse_table.py -i otutab_rare_tax_I.biom \
      -g ${sd}/FAPROTAX.txt \
      --collapse_by_metadata 'taxonomy' -v --force \
      -o faprotax_I.txt -r faprotax_report_I.txt

    ### 4. 制作OTU对应功能注释有无矩阵
    # 对ASV(OTU)注释行，及前一行标题进行筛选
    grep 'ASV_' -B 1 faprotax_report_I.txt | grep -v -P '^--$' > faprotax_report_I.clean
    # faprotax_report_sum.pl脚本将数据整理为表格，位于public/scrit中
    perl ${sd}/../faprotax_report_sum.pl -i faprotax_report_I.clean -o faprotax_report_I
    # 查看功能有无矩阵，-S不换行,control+z退出
    
    less -S faprotax_report_I.mat
    
    ### 作图可用代码，也可用在线网站。本研究这部分使用ImageGP网站作图。
    ### Figure2.D
    # 作图代码见 result/faprotax2/Dodge_barplot.Rmd
   
   

## 3. Bugbase细菌表型预测

    ### 1. Bugbase命令行分析
  
    # 本地版本
    wd=/c/16S
    db=/c/EasyMicrobiome-master
    PATH=$PATH:${db}/win
    
    
    cd ${wd}/result
    bugbase=${db}/script/BugBase
    # mkdir -p bugbase_premedpost
    # rm -rf bugbase_premedpost/
    
    # 脚本已经优化适合R4.0，biom包更新为biomformat
    Rscript ${bugbase}/bin/run.bugbase.r -L ${bugbase} \
      -i gg/otutab.txt -m metadata.txt -c State -o bugbase_new/

    ### 2. 其它可用分析
    # 使用 http://www.bic.ac.cn/ImageGP/index.php/Home/Index/BugBase.html
    # 官网，https://bugbase.cs.umn.edu/ ，有报错，不推荐
    # Bugbase细菌表型预测Linux，详见附录3. Bugbase细菌表型预测


# 32、MachineLearning机器学习

    # RandomForest包使用的R代码见advanced/RandomForestClassification和RandomForestRegression
    ## Silme2随机森林/Adaboost使用代码见EasyMicrobiome/script/slime2目录中的slime2.py，详见附录4
    # 使用实战(使用QIIME 2的Python3环境，以在Windows中为例)
   
    #  # 下载、安装和启动conda
    # wget -c https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    # bash Miniconda3-latest-Linux-x86_64.sh -b -f
    # ~/miniconda3/condabin/conda init
    # source ~/.bashrc
    
    conda activate qiime2-2023.7
    cd /mnt/c/EasyMicrobiome-master/script/slime2
    #使用adaboost计算10000次(16.7s)，推荐千万次
    ./slime2.py otutab.txt design.txt --normalize --tag ab_e4 ab -n 10000
    #使用RandomForest计算10000次(14.5s)，推荐百万次，支持多线程
    ./slime2.py otutab.txt design.txt --normalize --tag rf_e4 rf -n 10000
    
    
    # Figure2.E 
    # 运行完上面代码后自己出图。
    


# 33、Evolution进化树

    cd ${wd}
    mkdir -p result/tree2
    cd ${wd}/result/tree2

## 1. 筛选高丰度/指定的特征

    #方法1. 按丰度筛选特征，一般选0.001或0.005，且OTU数量在30-150个范围内
    #统计特征表中ASV数量，如总计1609个
    tail -n+2 ../otutab_rare.txt | wc -l
    #按相对丰度0.2%筛选高丰度OTU
    usearch -otutab_trim ../otutab_rare.txt \
        -min_otu_freq 0.002 \
        -output otutab_tree.txt
    #统计筛选OTU表特征数量，总计~98个
    tail -n+2 otutab_tree.txt | wc -l

    #方法2. 按数量筛选
    # #按丰度排序，默认由大到小
    # usearch -otutab_sortotus ../otutab_rare.txt  \
    #     -output otutab_sort.txt
    # #提取高丰度中指定Top数量的OTU ID，如Top100,
    # sed '1 s/#OTU ID/OTUID/' otutab_sort.txt \
    #     | head -n101 > otutab.txt

    #修改特征ID列名
    sed -i '1 s/#OTU ID/OTUID/' otutab_tree.txt
    #提取ID用于提取序列
    cut -f 1 otutab_tree.txt > otutab_high.id
    #head -n 2 otutab_high.id
    # 筛选高丰度菌/指定差异菌对应OTU序列
    #head -n 2 ../otus.fa
    usearch -fastx_getseqs ../otus.fa -labels otutab_high.id \
        -fastaout otus.fa
    head -n 2 otus.fa

    ## 筛选OTU对物种注释
    awk 'NR==FNR{a[$1]=$0} NR>FNR{print a[$1]}' ../taxonomy.txt \
        otutab_high.id > otutab_high.tax

    #获得OTU对应组均值，用于样本热图
    #依赖之前otu_mean.R计算过按Group分组的均值
    awk 'NR==FNR{a[$1]=$0} NR>FNR{print a[$1]}' ../otutab_mean_DHI.txt otutab_high.id \
        | sed 's/#OTU ID/OTUID/' > otutab_high.mean
    head -n3 otutab_high.mean

    #合并物种注释和丰度为注释文件
    cut -f 2- otutab_high.mean > temp
    paste otutab_high.tax temp > annotation.txt
    head -n 3 annotation.txt

## 2. 构建进化树

    # 起始文件为 result/tree目录中 otus.fa(序列)、annotation.txt(物种和相对丰度)文件
    # Muscle软件进行序列对齐，3s
    muscle -in otus.fa -out otus_aligned.fas

    ### 方法1. 利用IQ-TREE快速构建ML进化树，2m
    rm -rf iqtree
    mkdir -p iqtree
    iqtree -s otus_aligned.fas \
        -bb 1000 -redo -alrt 1000 -nt AUTO \
        -pre iqtree/otus

    ### 方法2. FastTree快速建树(Linux)
    # 注意FastTree软件输入文件为fasta格式的文件，而不是通常用的Phylip格式。输出文件是Newick格式。
    # 该方法适合于大数据，例如几百个OTUs的系统发育树！
    # Ubuntu上安装fasttree可以使用`apt install fasttree`
    # fasttree -gtr -nt otus_aligned.fas > otus.nwk

## 3. 进化树美化

    # 访问http://itol.embl.de/，上传otus.nwk，再拖拽下方生成的注释方案于树上即美化

    ## 方案1. 外圈颜色、形状分类和丰度方案
    # annotation.txt OTU对应物种注释和丰度，
    # -a 找不到输入列将终止运行（默认不执行）-c 将整数列转换为factor或具有小数点的数字，-t 偏离提示标签时转换ID列，-w 颜色带，区域宽度等， -D输出目录，-i OTU列名，-l OTU显示名称如种/属/科名，
    # cd ${wd}/result/tree
    Rscript ${db}/script/table2itol.R -a -c double -D plan1 -i OTUID -l Genus -t %s -w 0.5 annotation.txt
    # 生成注释文件中每列为单独一个文件
    
    # Rscript ${db}/script/table2itol.R -h


    ## 方案2. 生成丰度柱形图注释文件
    Rscript ${db}/script/table2itol.R -a -d -c none -D plan2 -b Phylum -i OTUID -l Genus -t %s -w 0.5 annotation.txt

    Rscript ${db}/script/table2itol.R -a -d -c none -D plan6 -b Family -i OTUID -l Phylum -t %s -w 0.5 annotation.txt
    
    ## 方案3. 生成热图注释文件
    Rscript ${db}/script/table2itol.R -c keep -D plan3 -i OTUID -t %s otutab_tree.txt

    ## 方案4. 将整数转化成因子生成注释文件
    Rscript ${db}/script/table2itol.R -a -c factor -D plan4 -i OTUID -l Genus -t %s -w 0 annotation.txt

    # 树iqtree/otus.contree在 http://itol.embl.de/ 上展示，拖拽不同Plan中的文件添加树注释

    # 返回工作目录
    cd ${wd}

## 4. 进化树可视化

   # https://www.bic.ac.cn/BIC/#/ 提供了更简易的可视化方式
   ## Figure2.A 使用ITOL网站出图，方便快捷。
    # 树iqtree/otus.contree在 http://itol.embl.de/ 上展示，拖拽不同Plan中的文件添加树注释
   
   
   



### 微生物网络分析

## Figure4.A，B 需要使用 result/ggclusternet/ggclusternet_main_pipeline_new.Rmd 脚本。需要再打开一个RStudio project这样更方便。
# Figure4.B 使用网站绘制，还未换成代码。


## Figure4.C,D,F 需要使用 result/clusternetanalysis/Net_analysis_main_pipeline.Rmd 脚本。需要再打开一个RStudio project这样更方便。


## Figure4.E  代码见result/ggclusternet/boxplot_of_network.Rmd 脚本。




### 随机森林分析

## 所有分析代码见 result/randomforestclassification/RF_classification_S_E.Rmd 脚本。
#  以Figure5.A为例，跑整个流程。















   
   
   
   
   
   

