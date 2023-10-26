
![Logo](https://i.imgur.com/EX5ZH6o.png)


# T_T | Drifting System

Um sistema de drifting para QBCore - by Trickster.





# Instalação

A instalação é bem simples e rápida, basta seguir os passos abaixo:

## Instalação do script base:
- Copie a pasta **[T_T]** para a pasta **resources** do seu servidor;
- No arquivo **server.cfg**, na mesma parte onde você carrega os demais scripts, adicione a seguinte linha:

```cfg
ensure [T_T]
```

## Criação dos itens

São necessários 3 itens para o script funcionar. São eles:
- Pneus de Drifting
- Kit Ângulo
- Diferencial Blocante

Para criar eles, adicione as linhas abaixo no arquivo:
### **[qb]/qb-core/shared/items.lua**
*(No final do arquivo)*

```lua
  -- Drifting System
  ['drifting_tyres'] = {
    ['name'] = 'drifting_tyres',
    ['label'] = 'Pneus de Drift',
    ['weight'] = 1000,
    ['type'] = 'item',
    ['image'] = 'drifting_tyres.png',
    ['unique'] = false,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'Um kit de pneus de drift'
  },
  ['differential'] = {
    ['name'] = 'differential',
    ['label'] = 'Diferencial Blocante',
    ['weight'] = 2000,
    ['type'] = 'item',
    ['image'] = 'differential.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'Um diferencial blocante'
  },
  ['steer_kit'] = {
    ['name'] = 'steer_kit',
    ['label'] = 'Kit Ângulo',
    ['weight'] = 2000,
    ['type'] = 'item',
    ['image'] = 'steer_kit.png',
    ['unique'] = true,
    ['useable'] = true,
    ['shouldClose'] = true,
    ['combinable'] = nil,
    ['description'] = 'Kit Ângulo'
  },
```

## Criação da Tabela no Banco de dados

O script acompanha um arquivo **SQL** de nome ***drifting.sql***. Basta abri-lo e executa-lo no seu banco de dados do servidor.
*(drifting.sql)*
```sql
CREATE TABLE `drifting` (
  `id` int(11) NOT NULL,
  `plate` varchar(32) NOT NULL,
  `tyres` int(11) DEFAULT NULL,
  `differential` int(11) DEFAULT NULL,
  `steer_kit` int(11) DEFAULT NULL,
  `wear` double DEFAULT NULL,
  `original_handling` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

ALTER TABLE `drifting` ADD PRIMARY KEY (`id`);

ALTER TABLE `drifting`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;
COMMIT;
```

## Imagens (qb-inventory) (Opcional)
O script também tem suporte ao sistema de inventário padrão da QB-Core (qb-inventory). 

Para adicionar as imagens, copie todas as imagens da pasta 
- **[T_T]/T_T-drifting-system/images**

E cole na pasta: 
- **[qb]/qb-inventory/html/images**


## Integração com a HUD (qb-hud) (Opcional):
O script tem suporte a integração com a QB-HUD para exibir o nível de desgaste dos pneus.
Para ativar a integração, siga os passos abaixo:

Adicione o **HTML** abaixo no arquivo: 
### **[qb]/qb-hud/html/index.html**
*(#main-container -> #ui-container)*

```html
<transition name="fade">
    <div v-if="showWheel">
    <q-circular-progress class="q-ml-xl" style="opacity: 40%;" :value="static" :thickness="0.24" color="{color: wheelColor}" :min="0" :max="100"></q-circular-progress>
    <q-circular-progress class="q-ml-xl" style="left: -50%;" show-value :value="wheelWear" :thickness="0.24" color="{color: wheelColor}" :min="0" :max="100" center-color="grey-10">
    <q-icon id="Icons" name="fas fa-hurricane" :style="{color: wheelColor}"/>
    </div>
</transition>
```

### Adicione as seguintes linhas no arquivo: 
#### **[qb]/qb-hud/client.lua**
*(No começo do arquivo, onde são instânciadas as variáveis globais)*
```lua
local wheelWear = 0
```

*(Procure pelos eventos de atualização da HUD (Ex.: hud:client:UpdateNitrous). Depois disso, entre um evento e outro coloque o seguinte evento):*
```lua
RegisterNetEvent('hud:client:UpdateWheelWear', function(wWhear)
    wheelWear = wWhear
end)
```

*(Procure pela função **updatePlayerHud** e dentro dela vá até a função **SendNUIMessage** e adicione o seguinte parâmetro no final):*
```lua
wheelWear = data[32],
```

*(Procure pelo loop de update da Hud (Você pode encontrar atráves da função **updatePlayerHud**). Dentro dele, você terá duas funções de nome **updatePlayerHud**, uma delas será referente a quando o Player está a pé e outra no veículo, na função onde o Player está no veículo, adicione o seguinte parâmetro no final dela):*
```lua
wheelWear,
```

### Adicione as seguintes linhas no arquivo: 
#### **[qb]/qb-hud/html/app.js**
*(Procure pela contante de nome **playerHud** ela terá uma função **data**, adicione os seguintes parâmetros dentro dela):*
```js
wheelWear: 100,
showWheel: false,
wheelColor: "#6600cc",
```
*(Procure pela contante de nome **playerHud** ela terá uma função **methods/hudTick** , adicione o seguinte parâmetro dentro dela):*
```js
this.wheelWear = data.wheelWear;
```
*(Na mesma função, um pouco mais abaixo, você vai encontrar vários condicionais, entre um e outro, coloque as seguintes linhas):*
```js
if (data.wheelWear >= 95) {
    this.showWheel = false;
} else if  (data.engine < 0){
    this.showWheel = false;
} else {
    this.showWheel = true;
}

if (data.wheelWear <= 25) {
    this.wheelColor = "#ff0000";
} else if (data.wheelWear <= 50 && data.wheelWear >= 26 ) {
    this.wheelColor = "#dd6e14";
} else if(data.wheelWear<=100) {
    this.wheelColor = "#3FA554";
}
```



