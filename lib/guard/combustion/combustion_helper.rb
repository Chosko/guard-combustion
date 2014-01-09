#
# Questa classe contiene funzioni utili per la gestione automatica di combustion con guard
# 
# Per configurare la porta utilizzata da combustion, inserire in un file ".guard_combustion_port" la porta desiderata (solo il numero).
# Se questo file non esiste, viene creato automaticamente al primo utilizzo di guard, utilizzando la porta di default.
# 
# NB: .guard_combustion_port è gitignored.
#
class CombustionHelper

  #
  # La porta di default utilizzata da combustion.
  # Questa porta viene utilizzata solo se non è già stata configurata in .guard_combustion_port
  # 
  # NB: per modificare la porta che si vuole far utilizzare a combustion non modificare direttamente questa variabile.
  #     Leggere invece le istruzioni in cima alla classe
  # 
  @@default_port = 9292
  @@last_start = Time.now - 5
  @@combustion_pid_file = "./tmp/.combustion_pid"
  @@guard_combustion_port = ".guard_combustion_port"

  #
  # Definisce tutti i metodi come statici
  # 
  class << self
    #
    # Avvia combustion
    # 
    def start_combustion
      if get_combustion_pid.nil?
        puts "starting combustion..."
        combustion_port = get_guard_combustion_port
        `#{combustion_cmd(combustion_port)}`
        sleep(1)
        @@last_start = Time.now
        pid = get_combustion_pid
        if pid.nil?
          puts "something went wrong, likely combustion were not started"
        else
          puts "\033[22;32mcombustion started and listening at port #{combustion_port} with pid #{pid}\x1b[0m"
        end
      else
        puts "another instance of combustion is already running with pid #{pid}"
      end
    end

    #
    # Uccide combustion
    # 
    def stop_combustion
      puts "stopping combustion..."
      pid = get_combustion_pid
      if pid.nil?
        puts "no instances of combustion were found, trying to kill it by command signature..."
        command = combustion_cmd get_guard_combustion_port
        puts `PSLINE=$(ps aux | grep "#{command}" | grep -v grep); IFS=' ' read -ra ADDR <<< $PSLINE; if [[ -n ${ADDR[1]} ]]; then kill -9 ${ADDR[1]}; echo "#{command} killed"; else echo "process #{command} not found: there wasn't any instance of combustion alive at all"; fi;`
      else
        `kill -9 #{pid}`
        puts "\033[22;31mcombustion stopped\x1b[0m"
        delete_combustion_pid
      end
    end

    #
    # Riavvia combustion
    # 
    def restart_combustion
      if Time.now > @@last_start + 1 # Controlla che il server non sia stato già avviato meno di 1 secondo fa
        puts "\033[01;33mrestarting combustion...\x1b[0m"
        stop_combustion
        start_combustion
      end
    end

  private

    #
    # Scrive la porta di default che verrà utilizzata per combustion in un file .guard_combustion_port
    # 
    def set_guard_combustion_port
      file = File.open(@@guard_combustion_port, "w")
      file.write(@@default_port.to_s)
      file.close
      @@default_port
    end

    #
    # Legge la porta di default che viene utilizzata per combustion dal file .guard_combustion_port
    # Se il file non esiste, lo crea e gli assegna la porta di default
    # 
    def get_guard_combustion_port
      begin
        if File.exists? @@guard_combustion_port
          file = File.open(@@guard_combustion_port, "r")
          contents = file.read
          combustion_port = Integer(contents.split("\n")[0])
          file.close
          combustion_port
        else
          set_guard_combustion_port
        end
      rescue ArgumentError => e
        file.close
        set_guard_combustion_port
      end
    end

    # 
    # Legge il pid di combustion dal file .combustion_pid
    # 
    def get_combustion_pid
      begin
        if File.exists? @@combustion_pid_file
          file = File.open(@@combustion_pid_file, "r")
          contents = file.read
          combustion_pid = Integer(contents.split("\n")[0])
          file.close
          combustion_pid
        else
          nil
        end
      rescue ArgumentError => e
        file.close
        nil
      end
    end

    # 
    # Elimina il file .combustion_pid   
    # 
    def delete_combustion_pid
      if File.exists? @@combustion_pid_file
        File.delete(@@combustion_pid_file)
      end
    end

    #
    # Restituisce su una stringa il comando shell utilizzato per avviare combustion
    # 
    def combustion_cmd combustion_port
      "rackup -p #{combustion_port} -D -P #{@@combustion_pid_file}"
    end
  end
end